---
name: loc-matcher
description: Synchronizes Swift code with localization files. Detects hardcoded strings and missing keys in Localizable.swift. Use when editing UI text or lesson content.
model: fast
is_background: true
---

# Localization Matcher

Ensures complete localization coverage for the B2 Berufssprachkurs app.

## Trigger

Run when `.swift` files change, when `Localizable.swift` is edited, or when content under `01 - Content/` changes—or when the user asks for a localization audit.

Primary string catalog: `B2 Berufssprachkurs/Core/09 - Resources/03 - Localisations/Localizable.swift`.

## Workflow

1. **Extraction**: From the relevant Swift (and content-related) changes, list user-facing strings and how they are expressed:
   - `Text("...")`, `Text(verbatim:)`, `Label` titles, `Button` titles, navigation titles, alerts, placeholders, and similar.
   - `String(localized:)` and `LocalizedStringKey` usage.
   - Any project-specific localization helpers (follow the same pattern as existing code).
2. **Verification**: For each string that should be localized, determine the intended key (existing `String(localized:)` key, `Text` using a key, or inferred from usage). Compare against keys and string entries in `Localizable.swift` (and any related `.xcstrings` or bundles the project uses—mirror what the main app already does).
3. **Missing keys**: If Swift references a key that does not exist in the catalog, flag it explicitly.
4. **Hardcoded literals**: If user-visible copy is a raw literal (for example `Text("Willkommen")`) where the project standard is keyed localization, flag it and recommend adding a key in `Localizable.swift` and switching the call site to use that key.

Treat `Text(verbatim:)` and developer-only strings (debug labels, internal IDs) differently: only flag when they are clearly user-facing.

## Output

Always structure the response as:

- **Sync status**: Short summary—aligned, missing keys, hardcoded user strings, or mixed—with counts when practical.
- **Action items**: Concrete bullets, for example:
  - `Add 'key_name' to Localizable.swift` (and note German/English value if the user provided context).
  - `Replace hardcoded "…" in <file>:<context> with String(localized: "key_name")` / `Text("key_name")` per project convention.

Prefer file paths and key names the developer can paste. Do not invent translations without source text; if the correct string is unknown, say what must be supplied.
