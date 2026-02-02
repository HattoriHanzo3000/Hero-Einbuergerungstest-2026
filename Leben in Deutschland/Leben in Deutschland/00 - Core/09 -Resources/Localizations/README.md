# Localization Files

This directory contains all localization files for the "Leben in Deutschland" app.

## Structure

```
Resources/Localizations/
├── de.lproj/          # German (Deutsch)
│   └── Localizable.strings
├── en.lproj/          # English
│   └── Localizable.strings
├── ru.lproj/          # Russian (Русский)
│   └── Localizable.strings
└── uk.lproj/          # Ukrainian (Українська)
    └── Localizable.strings
```

## Supported Languages

- **German (de)** - Primary language
- **English (en)** - International support
- **Russian (ru)** - Eastern European support
- **Ukrainian (uk)** - Eastern European support

## Usage in Code

```swift
// Using the String+Localization extension
Text("eagle_greeting".localized)
Text("NEXT".localized)
Text("tab_settings_title".localized)
```

## Adding New Languages

1. Create new `.lproj` folder (e.g., `fr.lproj` for French)
2. Copy `Localizable.strings` from existing language
3. Translate all strings
4. Add to Xcode project
5. Update `LanguageOption.availableLanguages` if needed

## File Organization Benefits

- ✅ **Centralized** - All localization files in one place
- ✅ **Organized** - Clear folder structure
- ✅ **Scalable** - Easy to add new languages
- ✅ **Maintainable** - Easy to find and update strings
- ✅ **Clean** - Separated from source code
