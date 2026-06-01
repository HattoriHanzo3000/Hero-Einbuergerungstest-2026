#!/usr/bin/env python3
"""
Normalize legal-term capitalization in content_*.json.

Rules (see capitalization_rules.yaml):
  - RU/UK: capitalize the noun конституция/конституція (and case forms), not adjectives
    (конституционный / конституційний).
  - EN: capitalize "Basic Law" when referring to the German Grundgesetz.
  - DE: capitalize "Grundgesetz".
  - TR: capitalize "Temel Yasa" as a fixed phrase.

Usage:
  python3 Scripts/fix_content_capitalization.py              # dry run
  python3 Scripts/fix_content_capitalization.py --write      # apply
  python3 Scripts/fix_content_capitalization.py --check      # CI: exit 1 if fixes needed
  python3 Scripts/fix_content_capitalization.py --lang ru uk
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
CONTENT_DIR = (
    REPO_ROOT
    / "Leben in Deutschland"
    / "00 - Core"
    / "09 -Resources"
    / "Content"
)

STRING_KEYS = frozenset({"category", "subcategory", "text", "hint"})

# Noun only — negative lookahead excludes adjective stems (…цион… / …ційн…).
RU_CONSTITUTION_NOUN = re.compile(
    r"(?<![А-Яа-яЁё])конституци(я|и|ю|ей|ям|ями)(?!он)",
    re.IGNORECASE,
)
UK_CONSTITUTION_NOUN = re.compile(
    r"(?<![А-Яа-яІіЇїЄєҐґ])конституці(я|ї|ю|єю|ям|ями)(?!йн)",
    re.IGNORECASE,
)
EN_BASIC_LAW = re.compile(r"\bbasic law\b", re.IGNORECASE)
DE_GRUNDGESETZ = re.compile(r"\bgrundgesetz\b", re.IGNORECASE)
TR_TEMEL_YASA = re.compile(r"\btemel yasa\b", re.IGNORECASE)


def apply_language_rules(text: str, language: str) -> str:
    if language == "ru":
        text = RU_CONSTITUTION_NOUN.sub(
            lambda m: "Конституци" + m.group(1).lower(), text
        )
    elif language == "uk":
        text = UK_CONSTITUTION_NOUN.sub(
            lambda m: "Конституці" + m.group(1).lower(), text
        )
    elif language == "en":
        text = EN_BASIC_LAW.sub("Basic Law", text)
    elif language == "de":
        text = DE_GRUNDGESETZ.sub("Grundgesetz", text)
    elif language == "tr":
        text = TR_TEMEL_YASA.sub("Temel Yasa", text)
    return text


def update_strings(node: object, language: str, changes: list[dict], path: str) -> None:
    if isinstance(node, dict):
        for key, value in node.items():
            child_path = f"{path}.{key}" if path else key
            if key in STRING_KEYS and isinstance(value, str):
                updated = apply_language_rules(value, language)
                if updated != value:
                    changes.append(
                        {
                            "location": child_path,
                            "before": value,
                            "after": updated,
                        }
                    )
                    node[key] = updated
            elif key == "options" and isinstance(value, list):
                for index, option in enumerate(value):
                    if not isinstance(option, str):
                        continue
                    option_path = f"{child_path}[{index}]"
                    updated = apply_language_rules(option, language)
                    if updated != option:
                        changes.append(
                            {
                                "location": option_path,
                                "before": option,
                                "after": updated,
                            }
                        )
                        value[index] = updated
            else:
                update_strings(value, language, changes, child_path)
    elif isinstance(node, list):
        for index, item in enumerate(node):
            update_strings(item, language, changes, f"{path}[{index}]")


def question_id_for_path(data: list, location: str) -> str | None:
    """Best-effort question id for change reports."""
    match = re.search(r"questions\[(\d+)\]", location)
    if not match:
        return None
    try:
        q_index = int(match.group(1))
        block = data[0]
        for segment in location.split("."):
            if segment.startswith("content["):
                c_index = int(segment[8:-1])
                block = block["content"][c_index]
            elif segment.startswith("questions["):
                continue
        questions = block.get("questions", [])
        if q_index < len(questions):
            return questions[q_index].get("id")
    except (KeyError, IndexError, TypeError):
        pass
    return None


def process_file(path: Path, *, write: bool) -> list[dict]:
    data = json.loads(path.read_text(encoding="utf-8"))
    language = data[0].get("language", "") if data else ""

    raw_changes: list[dict] = []
    update_strings(data, language, raw_changes, "")

    changes: list[dict] = []
    for item in raw_changes:
        qid = question_id_for_path(data, item["location"])
        changes.append(
            {
                "file": str(path.relative_to(REPO_ROOT)),
                "location": item["location"],
                "question_id": qid,
                "before": item["before"],
                "after": item["after"],
            }
        )

    if changes and write:
        path.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )

    return changes


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--write",
        action="store_true",
        help="Apply changes to JSON files (default: dry run)",
    )
    parser.add_argument(
        "--check",
        action="store_true",
        help="Exit 1 if any file would change (implies dry run)",
    )
    parser.add_argument(
        "--lang",
        action="append",
        choices=["de", "en", "ru", "uk", "tr"],
        help="Limit to language code(s); repeatable",
    )
    args = parser.parse_args()

    if args.check and args.write:
        parser.error("--check cannot be combined with --write")

    files = sorted(CONTENT_DIR.glob("content_*.json"))
    if args.lang:
        allowed = set(args.lang)
        files = [f for f in files if f.stem.removeprefix("content_") in allowed]

    all_changes: list[dict] = []
    for file_path in files:
        all_changes.extend(process_file(file_path, write=args.write))

    for change in all_changes:
        qid = change["question_id"]
        suffix = f" (id {qid})" if qid else ""
        print(f"{change['file']}{suffix}")
        print(f"  {change['location']}")
        print(f"  - {change['before']}")
        print(f"  + {change['after']}")
        print()

    print(f"Total changes: {len(all_changes)}")
    if all_changes and not args.write:
        print("Dry run. Re-run with --write to apply.")
    elif all_changes and args.write:
        print("Applied.")

    if args.check and all_changes:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
