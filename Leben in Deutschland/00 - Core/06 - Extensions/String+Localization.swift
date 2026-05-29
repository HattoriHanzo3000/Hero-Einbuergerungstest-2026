import Foundation

// MARK: - String Localization Extension
/// German is the base language (matches Xcode project default localization).
extension String {
    var localized: String {
        let languageCode = UserDefaults.standard.string(forKey: "appLanguage") ?? LanguageManager.baseLanguageCode
        return self.localized(for: languageCode)
    }

    func localized(for languageCode: String) -> String {
        // 1. Try standard .lproj bundle at root
        if let lprojPath = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: lprojPath) {
            return NSLocalizedString(self, bundle: bundle, comment: "")
        }
        // 2. Try Localizable.strings path inside .lproj (alternative bundle layout)
        if let stringsURL = Bundle.main.url(forResource: "Localizable", withExtension: "strings", subdirectory: "\(languageCode).lproj"),
           let bundle = Bundle(url: stringsURL.deletingLastPathComponent()) {
            return NSLocalizedString(self, bundle: bundle, comment: "")
        }
        // 3. Fallback to main bundle default (Xcode development language)
        let fallback = NSLocalizedString(self, comment: "")
        if fallback != self { return fallback }
        // 4. Last resort: try German bundle (base language)
        if languageCode != LanguageManager.baseLanguageCode,
           let dePath = Bundle.main.path(forResource: LanguageManager.baseLanguageCode, ofType: "lproj"),
           let deBundle = Bundle(path: dePath) {
            return NSLocalizedString(self, bundle: deBundle, comment: "")
        }
        return self
    }
    
    func localizedUppercased() -> String {
        localized.uppercased(with: Locale(identifier: LanguageManager.currentAppLanguageCode))
    }
}
