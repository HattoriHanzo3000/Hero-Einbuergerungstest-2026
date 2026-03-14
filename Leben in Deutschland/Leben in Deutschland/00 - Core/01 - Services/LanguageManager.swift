import Foundation
import SwiftUI
import Combine

// MARK: - Language Manager
/// German is the base/default language for "Leben in Deutschland" (matches Xcode project default localization).
class LanguageManager: ObservableObject {
    /// Base language: German. Used when user hasn't selected one and as fallback everywhere.
    static let baseLanguageCode = "de"

    @Published var currentAppLanguage: String = "de"
    @Published var currentTranslationLanguage: String = "de"
    /// Shown when applying language change to hide the view rebuild flash
    @Published var isApplyingLanguageChange: Bool = false

    static var currentAppLanguageCode: String {
        UserDefaults.standard.string(forKey: "appLanguage") ?? Self.baseLanguageCode
    }

    init() {
        loadSavedLanguages()
        // Ensure appLanguage is set on first launch so all UI uses German from the start
        if UserDefaults.standard.string(forKey: "appLanguage") == nil {
            UserDefaults.standard.set(Self.baseLanguageCode, forKey: "appLanguage")
        }
    }
    
    // MARK: - Language Management
    
    func setAppLanguage(_ code: String) {
        currentAppLanguage = code
        UserDefaults.standard.set(code, forKey: "appLanguage")
        
        // Ensure translation language is different
        if currentTranslationLanguage == code {
            let fallback = ["de", "en", "ru"].first { $0 != code } ?? "de"
            setTranslationLanguage(fallback)
        }
    }
    
    func setTranslationLanguage(_ code: String) {
        // Keep translation different from interface language
        guard code != currentAppLanguage else { return }
        currentTranslationLanguage = code
        UserDefaults.standard.set(code, forKey: "translationLanguage")
    }
    
    // MARK: - Locale
    
    var currentLocale: Locale {
        switch currentAppLanguage {
        case "ru": return Locale(identifier: "ru_RU")
        case "de": return Locale(identifier: "de_DE")
        default: return Locale(identifier: "de_DE")
        }
    }
    
    // MARK: - Private Methods
    
    private func loadSavedLanguages() {
        currentAppLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? Self.baseLanguageCode
        if let saved = UserDefaults.standard.string(forKey: "translationLanguage") {
            currentTranslationLanguage = saved
        } else if let migrated = OnboardingPreferences.shared.translationLanguageCode,
                  migrated != currentAppLanguage {
            // Migrate from onboarding preference (first launch after completing onboarding)
            currentTranslationLanguage = migrated
            UserDefaults.standard.set(migrated, forKey: "translationLanguage")
        } else {
            currentTranslationLanguage = "de"
        }
    }
}
