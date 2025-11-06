import Foundation
import SwiftUI
import Combine

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
        // Preselect nothing; ensure dialog appears after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + OnboardingConstants.dialogDelay) {
            self.showDialog = true
        }
    }
    
    func selectLanguage(_ language: String) {
        selectedLanguage = language
        let code = getLanguageCode(for: language)
        preferences.translationLanguageCode = code
        preferences.translationSelected = true
    }
    
    func proceedToNext() { onNext?() }
    func goBack() { onBack?() }
    
    private func getLanguageCode(for language: String) -> String {
        switch language.lowercased() {
        case "deutsch": return "de"
        case "english": return "en"
        case "русский": return "ru"
        case "українська": return "uk"
        default: return "de"
        }
    }
}


