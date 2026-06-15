import Foundation
import SwiftUI
import Combine

// MARK: - Onboarding Translation ViewModel
@MainActor
class OnboardingTranslationViewModel: ObservableObject {
    @Published var selectedLanguage: String?
    @Published var showDialog: Bool = false
    
    /// Header message: same text whether selected or not (call to action)
    var dialogMessageKey: String {
        "translation_selection_title"
    }
    
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
        // Only restore when user had previously selected (returning from a later step)
        if preferences.translationSelected, let savedTranslationCode = preferences.translationLanguageCode {
            if let languageOption = LanguageOption.availableLanguages.first(where: { $0.languageCode == savedTranslationCode }) {
                selectedLanguage = languageOption.name
                if savedTranslationCode != languageManager.currentAppLanguage {
                    languageManager.setTranslationLanguage(savedTranslationCode)
                }
            }
        } else {
            selectedLanguage = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + OnboardingConstants.dialogDelay) {
            self.showDialog = true
        }
    }
    
    func selectLanguage(_ language: String) {
        selectedLanguage = language
        let code = LanguageOption.getLanguageCode(for: language)
        guard code != languageManager.currentAppLanguage else { return }
        languageManager.setTranslationLanguage(code)
        preferences.translationLanguageCode = code
        preferences.translationSelected = true
    }
    
    func proceedToNext() { onNext?() }
    func goBack() { onBack?() }
}
