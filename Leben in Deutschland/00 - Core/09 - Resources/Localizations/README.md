# Localization

UI strings for **Leben in Deutschland** live in a single String Catalog. Exam question text stays in per-language JSON files (`content_*.json`) loaded by `ContentService`.

## Structure

```
Resources/Localizations/
└── Localizable.xcstrings    # All UI strings (de, en, ru, tr)
```

Xcode compiles the catalog into `de.lproj`, `en.lproj`, etc. at build time. Do not add parallel `Localizable.strings` files — the build fails if both exist.

## Supported languages

| Code | Language |
|------|----------|
| `de` | German (source / default) |
| `en` | English |
| `ru` | Russian |
| `tr` | Turkish |

App language is chosen in Settings via `LanguageManager` (not the system locale). The `"key".localized` helpers load the matching compiled `.lproj` bundle.

## Usage in code

```swift
Text("tab_settings_title".localized)
Text("paywall_title".localized(for: languageCode))

// Formatted strings
"test_results_x_of_y".localizedFormat(item.correct, item.total)

// String Catalog plural variants
"perfect_days_remaining".localizedPlural(days)
"search_results_count".localizedPlural(searchResults.count)
```

Helpers live in `String+Localization.swift` (`localized`, `localized(for:)`, `localizedFormat`, `localizedPlural`, `localizedUppercased`).

Use **semantic keys** (`settings_app_language`, `paywall_title`) — not English sentence keys for new strings.

## Adding or editing strings

1. Open `Localizable.xcstrings` in Xcode.
2. Add a key (or select an existing one).
3. Fill in translations for each locale column.
4. For plurals, set the key type to **Plural** and define `one` / `few` / `many` / `other` per language.
5. Reference the key in Swift as `"your_key".localized`.

Prefer translator comments in the catalog’s comment field for non-obvious copy.

## Adding a new language

1. In Xcode, select `Localizable.xcstrings` → add a locale (e.g. `fr`).
2. Translate all keys (or export/import XLIFF via **Editor → Export/Import Localizations**).
3. Add the locale to the app target’s **Localizations** in project settings if needed.
4. Update `LanguageManager` / settings language options so users can select it.

## What does not belong here

- **Question text, answers, hints** → JSON content files, not the String Catalog.
- **Debug-only labels** (e.g. `DebugMenuSheet`) → may stay hardcoded in English.
