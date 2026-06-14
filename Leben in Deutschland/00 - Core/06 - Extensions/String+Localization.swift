import Foundation

// MARK: - Localization Bundle

/// Resolves language-specific bundles compiled from `Localizable.xcstrings`.
enum LocalizationBundle {
    static func bundle(for languageCode: String) -> Bundle {
        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        if languageCode != LanguageManager.baseLanguageCode,
           let path = Bundle.main.path(forResource: LanguageManager.baseLanguageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return .main
    }
}

// MARK: - String Localization Extension

/// German is the base language (matches Xcode project default localization).
extension String {
    var localized: String {
        localized(for: LanguageManager.currentAppLanguageCode)
    }

    func localized(for languageCode: String) -> String {
        String(
            localized: String.LocalizationValue(self),
            bundle: LocalizationBundle.bundle(for: languageCode)
        )
    }

    func localizedUppercased(for languageCode: String = LanguageManager.currentAppLanguageCode) -> String {
        localized(for: languageCode).uppercased(with: Locale(identifier: languageCode))
    }

    func localizedFormat(_ arguments: CVarArg..., languageCode: String = LanguageManager.currentAppLanguageCode) -> String {
        String(
            format: localized(for: languageCode),
            locale: Locale(identifier: languageCode),
            arguments: arguments
        )
    }

    /// Resolves a String Catalog entry with `plural` variations for the given count.
    func localizedPlural(_ count: Int, languageCode: String = LanguageManager.currentAppLanguageCode) -> String {
        let locale = Locale(identifier: languageCode)
        let bundle = LocalizationBundle.bundle(for: languageCode)
        let format = String(localized: String.LocalizationValue(self), bundle: bundle, locale: locale)
        return String(format: format, locale: locale, count)
    }
}
