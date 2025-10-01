import Foundation

// MARK: - Language Option Model
struct LanguageOption: Identifiable {
    let id = UUID()
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
    static let availableLanguages = [
        LanguageOption(
            name: "English",
            nativeName: "English",
            isSelected: false,
            languageCode: "en"
        ),
        LanguageOption(
            name: "Deutsch",
            nativeName: "Deutsch",
            isSelected: true,
            languageCode: "de"
        ),
        LanguageOption(
            name: "Русский",
            nativeName: "Русский",
            isSelected: false,
            languageCode: "ru"
        )
    ]
}
