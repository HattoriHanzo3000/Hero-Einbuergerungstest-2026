import SwiftUI
import Combine

// MARK: - Onboarding Translation ViewModel
class OnboardingTranslationViewModel: ObservableObject {
    @Published var selectedLanguage: String?
    @Published var showDialog: Bool = false
    
    let languageManager: LanguageManager
    private let preferences: OnboardingPreferences
    private let onNext: () -> Void
    private let onBack: () -> Void
    
    init(languageManager: LanguageManager, preferences: OnboardingPreferences = .shared, onNext: @escaping () -> Void = {}, onBack: @escaping () -> Void = {}) {
        self.languageManager = languageManager
        self.preferences = preferences
        self.onNext = onNext
        self.onBack = onBack
    }
    
    // MARK: - Public Methods
    
    func setupInitialState() {
        if preferences.hasLaunchedBefore, let savedCode = preferences.translationLanguageCode {
            selectedLanguage = mapCodeToName(savedCode)
        } else {
            selectedLanguage = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showDialog = true
        }
    }
    
    func selectLanguage(_ languageName: String) {
        HapticManager.shared.lightImpact()
        selectedLanguage = languageName
        
        // Get language code and set translation language
        let languageCode = getLanguageCode(for: languageName)
        languageManager.setTranslationLanguage(languageCode)
        preferences.translationSelected = true
        preferences.translationLanguageCode = languageCode
    }
    
    func proceedToNext() {
        if let selectedLang = selectedLanguage {
            let languageCode = getLanguageCode(for: selectedLang)
            languageManager.setTranslationLanguage(languageCode)
            preferences.translationSelected = true
            preferences.translationLanguageCode = languageCode
            onNext()
        }
    }
    
    func goBack() {
        onBack()
    }
    
    // MARK: - Helper Methods
    
    private func getLanguageCode(for languageName: String) -> String {
        switch languageName.lowercased() {
        case "deutsch": return "de"
        case "english": return "en"
        case "русский": return "ru"
        case "українська": return "uk"
        default: return "de"
        }
    }
    
    private func mapCodeToName(_ code: String) -> String? {
        switch code {
        case "de": return "Deutsch"
        case "en": return "English"
        case "ru": return "Русский"
        case "uk": return "Українська"
        default: return nil
        }
    }
    
    func isSameAsAppLanguage(languageName: String) -> Bool {
        let languageCode = getLanguageCode(for: languageName)
        return languageCode == languageManager.currentAppLanguage
    }
}
