import Foundation

// MARK: - String Localization Extension
extension String {
    var localized: String {
        // Read current app language chosen in-app
        let languageCode = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return NSLocalizedString(self, bundle: bundle, comment: "")
        }
        return NSLocalizedString(self, comment: "")
    }
}
