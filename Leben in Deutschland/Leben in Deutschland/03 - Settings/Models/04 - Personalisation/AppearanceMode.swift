import Foundation

// Enum representing app appearance modes
enum AppearanceMode: String, CaseIterable {
    case light
    case dark
    case system
    
    // Get localized display name for current mode
    var displayName: String {
        switch self {
        case .light:
            return "settings_appearance_light".localized
        case .dark:
            return "settings_appearance_dark".localized
        case .system:
            return "settings_appearance_system".localized
        }
    }
    
    // Get next mode in cycle (light -> dark -> system -> light)
    var next: AppearanceMode {
        switch self {
        case .light:
            return .dark
        case .dark:
            return .system
        case .system:
            return .light
        }
    }
    
    // Initialize from string stored in UserDefaults/AppStorage
    init(from string: String) {
        self = AppearanceMode(rawValue: string) ?? .system
    }
}


