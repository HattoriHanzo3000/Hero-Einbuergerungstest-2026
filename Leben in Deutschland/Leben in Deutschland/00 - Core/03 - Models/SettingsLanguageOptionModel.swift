import Foundation

enum SettingsAppLanguageOption: String, CaseIterable, Identifiable {
    case english = "en"
    case german = "de"
    case russian = "ru"
    case turkish = "tr"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "settings_language_option_english".localized
        case .german: return "settings_language_option_german".localized
        case .russian: return "settings_language_option_russian".localized
        case .turkish: return "settings_language_option_turkish".localized
        }
    }

    static var displayCases: [SettingsAppLanguageOption] { Array(allCases) }
}

enum SettingsTranslationLanguageOption: String, CaseIterable, Identifiable {
    case english = "en"
    case german = "de"
    case russian = "ru"
    case turkish = "tr"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "settings_language_option_english".localized
        case .german: return "settings_language_option_german".localized
        case .russian: return "settings_language_option_russian".localized
        case .turkish: return "settings_language_option_turkish".localized
        }
    }

    static var displayCases: [SettingsTranslationLanguageOption] { Array(allCases) }
}

