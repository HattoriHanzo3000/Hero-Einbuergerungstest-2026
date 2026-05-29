import Foundation
import SwiftUI
import Combine

// MARK: - Onboarding Language ViewModel
@MainActor
class OnboardingLanguageViewModel: ObservableObject {
    @Published var selectedLanguage: String?
    @Published var showDialog: Bool = false
    
    /// Single combined greeting (choose language + tap Next); updates when `currentAppLanguage` changes.
    var dialogMessageKey: String { "eagle_greeting" }
    
    let languageManager: LanguageManager
    private let preferences: OnboardingPreferences
    private let onNext: () -> Void
    
    init(languageManager: LanguageManager, preferences: OnboardingPreferences? = nil, onNext: @escaping () -> Void) {
        self.languageManager = languageManager
        self.preferences = preferences ?? OnboardingPreferences.shared
        self.onNext = onNext
    }
    
    // MARK: - Public Methods
    
    func setupInitialState() {
        // First time: no selection. When returning (hasLaunchedBefore): restore from app language
        if preferences.hasLaunchedBefore {
            let code = languageManager.currentAppLanguage
            switch code {
            case "de": selectedLanguage = "Deutsch"
            case "en": selectedLanguage = "English"
            case "ru": selectedLanguage = "Русский"
            case "tr": selectedLanguage = "Türkçe"
            case "uk": selectedLanguage = "Deutsch"; languageManager.setAppLanguage("de")
            default: selectedLanguage = "Deutsch"
            }
            ensureTranslationLanguageDifferent()
        } else {
            selectedLanguage = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + OnboardingConstants.dialogDelay) {
            self.showDialog = true
        }
    }
    
    func selectLanguage(_ language: String) {
        selectedLanguage = language
        let languageCode = LanguageOption.getLanguageCode(for: language)
        languageManager.setAppLanguage(languageCode)
        ensureTranslationLanguageDifferent()
    }
    
    func proceedToNext() {
        guard selectedLanguage != nil else { return }
        // Mark that first-launch flow has been initialized
        if !preferences.hasLaunchedBefore { preferences.hasLaunchedBefore = true }
        onNext()
    }
    
    // MARK: - Private Methods
    
    private func ensureTranslationLanguageDifferent() {
        let appLanguageCode = languageManager.currentAppLanguage
        let translationLanguageCode = preferences.translationLanguageCode
        
        // If translation language matches app language, unselect it
        if appLanguageCode == translationLanguageCode {
            preferences.translationSelected = false
            preferences.translationLanguageCode = nil
        }
    }
}
