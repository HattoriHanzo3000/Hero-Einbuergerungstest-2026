import Foundation
import SwiftUI
import Combine

// MARK: - Language Manager
class LanguageManager: ObservableObject {
    @Published var currentAppLanguage: String = "en"
    @Published var currentTranslationLanguage: String = "de"
    /// Shown when applying language change to hide the view rebuild flash
    @Published var isApplyingLanguageChange: Bool = false
    
    static var currentAppLanguageCode: String {
        UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
    }
    
    init() {
        loadSavedLanguages()
    }
    
    // MARK: - Language Management
    
    func setAppLanguage(_ code: String) {
        currentAppLanguage = code
        UserDefaults.standard.set(code, forKey: "appLanguage")
        
        // Ensure translation language is different
        if currentTranslationLanguage == code {
            let fallback = ["de", "en", "ru", "uk"].first { $0 != code } ?? "en"
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
        case "uk": return Locale(identifier: "uk_UA")
        default: return Locale(identifier: "en_US")
        }
    }
    
    // MARK: - Private Methods
    
    private func loadSavedLanguages() {
        currentAppLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
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
