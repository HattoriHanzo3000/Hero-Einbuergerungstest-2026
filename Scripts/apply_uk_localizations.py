#!/usr/bin/env python3
"""Merge Ukrainian localizations from uk_ui_translations.json into Localizable.xcstrings."""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
XCSTRINGS = ROOT / "Leben in Deutschland" / "Localizable.xcstrings"
TRANSLATIONS = Path(__file__).with_name("uk_ui_translations.json")


def make_simple(value: str) -> dict:
    return {
        "stringUnit": {
            "state": "translated",
            "value": value,
        }
    }


def make_plural(forms: dict[str, str]) -> dict:
    return {
        "variations": {
            "plural": {
                form: make_simple(text)
                for form, text in forms.items()
            }
        }
    }


def apply_uk_localizations() -> int:
    translations: dict = json.loads(TRANSLATIONS.read_text(encoding="utf-8"))
    catalog: dict = json.loads(XCSTRINGS.read_text(encoding="utf-8"))
    strings: dict = catalog["strings"]
    applied = 0

    for key, uk_value in translations.items():
        if key not in strings:
            strings[key] = {
                "extractionState": "manual",
                "localizations": {},
            }

        entry = strings[key]
        localizations = entry.setdefault("localizations", {})

        if isinstance(uk_value, dict):
            localizations["uk"] = make_plural(uk_value)
        else:
            localizations["uk"] = make_simple(uk_value)

        applied += 1

    # Add uk to existing language option keys that may already exist without uk.
    for lang_key in (
        "settings_language_option_english",
        "settings_language_option_german",
        "settings_language_option_russian",
        "settings_language_option_turkish",
    ):
        if lang_key in strings and "uk" not in strings[lang_key].get("localizations", {}):
            ref = strings[lang_key]["localizations"].get("en", {}).get("stringUnit", {}).get("value")
            if ref and lang_key in translations:
                strings[lang_key]["localizations"]["uk"] = make_simple(translations[lang_key])

    XCSTRINGS.write_text(
        json.dumps(catalog, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    return applied


def verify() -> list[str]:
    translations: dict = json.loads(TRANSLATIONS.read_text(encoding="utf-8"))
    catalog: dict = json.loads(XCSTRINGS.read_text(encoding="utf-8"))
    strings: dict = catalog["strings"]
    issues: list[str] = []

    for key in translations:
        if key not in strings:
            issues.append(f"missing catalog key: {key}")
            continue
        if "uk" not in strings[key].get("localizations", {}):
            issues.append(f"missing uk localization: {key}")

    return issues


def main() -> int:
    if "--check" in sys.argv:
        issues = verify()
        if issues:
            print("\n".join(issues))
            return 1
        print(f"OK: {len(json.loads(TRANSLATIONS.read_text()))} uk keys present")
        return 0

    count = apply_uk_localizations()
    issues = verify()
    if issues:
        print("\n".join(issues))
        return 1
    print(f"Applied {count} Ukrainian localizations to {XCSTRINGS.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
