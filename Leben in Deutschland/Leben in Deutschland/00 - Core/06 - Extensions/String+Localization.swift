import Foundation

// MARK: - String Localization Extension
extension String {
    var localized: String {
        let languageCode = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        return self.localized(for: languageCode)
    }

    func localized(for languageCode: String) -> String {
        // 1. Try standard .lproj bundle at root
        if let lprojPath = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: lprojPath) {
            let result = NSLocalizedString(self, bundle: bundle, comment: "")
            if result != self { return result }
        }
        // 2. Try Localizable.strings path inside .lproj (alternative bundle layout)
        if let stringsURL = Bundle.main.url(forResource: "Localizable", withExtension: "strings", subdirectory: "\(languageCode).lproj"),
           let bundle = Bundle(url: stringsURL.deletingLastPathComponent()) {
            let result = NSLocalizedString(self, bundle: bundle, comment: "")
            if result != self { return result }
        }
        // 3. Fallback to main bundle default
        let fallback = NSLocalizedString(self, comment: "")
        if fallback != self { return fallback }
        // 4. Last resort: try English bundle
        if languageCode != "en",
           let enPath = Bundle.main.path(forResource: "en", ofType: "lproj"),
           let enBundle = Bundle(path: enPath) {
            return NSLocalizedString(self, bundle: enBundle, comment: "")
        }
        return self
    }
    
    func localizedUppercased() -> String {
        localized.uppercased(with: Locale(identifier: LanguageManager.currentAppLanguageCode))
    }
}
