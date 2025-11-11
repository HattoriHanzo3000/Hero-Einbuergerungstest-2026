import Foundation
import SwiftUI
import Combine

// MARK: - Onboarding Translation ViewModel
@MainActor
class OnboardingTranslationViewModel: ObservableObject {
    @Published var selectedLanguage: String?
    @Published var showDialog: Bool = false
    
    let languageManager: LanguageManager
    private let preferences: OnboardingPreferences
    private let onNext: (() -> Void)?
    private let onBack: (() -> Void)?
    
    init(languageManager: LanguageManager, preferences: OnboardingPreferences? = nil, onNext: (() -> Void)? = nil, onBack: (() -> Void)? = nil) {
        self.languageManager = languageManager
        self.preferences = preferences ?? OnboardingPreferences.shared
        self.onNext = onNext
        self.onBack = onBack
    }
    
    func setupInitialState() {
        // Restore saved translation language if available
        if let savedTranslationCode = preferences.translationLanguageCode,
           let languageOption = LanguageOption.availableLanguages.first(where: { $0.languageCode == savedTranslationCode }) {
            selectedLanguage = languageOption.name
        }
        // Show dialog with delay
        DispatchQueue.main.asyncAfter(deadline: .now() + OnboardingConstants.dialogDelay) {
            self.showDialog = true
        }
    }
    
    func selectLanguage(_ language: String) {
        selectedLanguage = language
        let code = LanguageOption.getLanguageCode(for: language)
        preferences.translationLanguageCode = code
        preferences.translationSelected = true
    }
    
    func proceedToNext() { onNext?() }
    func goBack() { onBack?() }
}
