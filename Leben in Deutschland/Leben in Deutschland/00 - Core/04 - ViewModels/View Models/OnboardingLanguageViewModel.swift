import Foundation
import SwiftUI
import Combine

// MARK: - Onboarding Language ViewModel
@MainActor
class OnboardingLanguageViewModel: ObservableObject {
    @Published var selectedLanguage: String?
    @Published var showDialog: Bool = false
    
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
        // Only Language has a default preselection on first launch: English
        let code = languageManager.currentAppLanguage
        if preferences.hasLaunchedBefore {
            // Reflect saved app language
            switch code {
            case "de": selectedLanguage = "Deutsch"
            case "ru": selectedLanguage = "Русский"
            case "uk": selectedLanguage = "Українська"
            default: selectedLanguage = "English"
            }
        } else {
            // First launch: preselect English by design and set app language
            selectedLanguage = "English"
            languageManager.setAppLanguage("en")
        }
        
        // Ensure translation language is different from app language
        ensureTranslationLanguageDifferent()
        
        // Show dialog with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + OnboardingConstants.dialogDelay) {
            self.showDialog = true
        }
    }
    
    func selectLanguage(_ language: String) {
        selectedLanguage = language
        let languageCode = LanguageOption.getLanguageCode(for: language)
        languageManager.setAppLanguage(languageCode)
        
        // Ensure translation language stays different
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
