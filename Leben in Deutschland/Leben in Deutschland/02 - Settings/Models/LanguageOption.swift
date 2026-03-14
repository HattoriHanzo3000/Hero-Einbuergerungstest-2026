import Foundation

// MARK: - Language Option Model
struct LanguageOption: Identifiable {
    var id: String { languageCode } // Stable ID for SwiftUI diffing
    let name: String
    let nativeName: String
    let isSelected: Bool
    let languageCode: String
    
    init(name: String, nativeName: String, isSelected: Bool = false, languageCode: String) {
        self.name = name
        self.nativeName = nativeName
        self.isSelected = isSelected
        self.languageCode = languageCode
    }
}

// MARK: - Available Languages
extension LanguageOption {
    static var availableLanguages: [LanguageOption] {
        [
            LanguageOption(name: "Deutsch", nativeName: "Deutsch", isSelected: true, languageCode: "de"),
            LanguageOption(name: "English", nativeName: "English", isSelected: false, languageCode: "en"),
            LanguageOption(name: "Русский", nativeName: "Русский", isSelected: false, languageCode: "ru"),
        ]
    }
    
    // MARK: - Helper Methods
    
    /// Returns the language code for a given language name (case-insensitive)
    static func getLanguageCode(for languageName: String) -> String {
        let lowercasedName = languageName.lowercased()
        return availableLanguages.first { $0.name.lowercased() == lowercasedName }?.languageCode ?? "de"
    }
}
