import Foundation

/// Set to true to temporarily hide Ukrainian from settings dropdowns
private let isUkrainianDisabled = true

enum SettingsAppLanguageOption: String, CaseIterable, Identifiable {
    case english = "en"
    case german = "de"
    case russian = "ru"
    case ukrainian = "uk"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "settings_language_option_english".localized
        case .german: return "settings_language_option_german".localized
        case .russian: return "settings_language_option_russian".localized
        case .ukrainian: return "settings_language_option_ukrainian".localized
        }
    }

    /// Options shown in UI (excludes Ukrainian when disabled)
    static var displayCases: [SettingsAppLanguageOption] {
        if isUkrainianDisabled {
            return allCases.filter { $0 != .ukrainian }
        }
        return Array(allCases)
    }
}

enum SettingsTranslationLanguageOption: String, CaseIterable, Identifiable {
    case english = "en"
    case german = "de"
    case russian = "ru"
    case ukrainian = "uk"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "settings_language_option_english".localized
        case .german: return "settings_language_option_german".localized
        case .russian: return "settings_language_option_russian".localized
        case .ukrainian: return "settings_language_option_ukrainian".localized
        }
    }

    /// Options shown in UI (excludes Ukrainian when disabled)
    static var displayCases: [SettingsTranslationLanguageOption] {
        if isUkrainianDisabled {
            return allCases.filter { $0 != .ukrainian }
        }
        return Array(allCases)
    }
}

