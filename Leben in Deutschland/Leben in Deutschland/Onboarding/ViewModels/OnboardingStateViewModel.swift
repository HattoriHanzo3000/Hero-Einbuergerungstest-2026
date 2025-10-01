import Foundation
import SwiftUI
import Combine

// MARK: - Onboarding State ViewModel
class OnboardingStateViewModel: ObservableObject {
    @Published var selectedState: String?
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
        if !preferences.hasLaunchedBefore {
            selectedState = nil
        } else {
            selectedState = UserDefaults.standard.string(forKey: "selectedState")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + OnboardingConstants.dialogDelay) {
            self.showDialog = true
        }
    }
    
    func selectState(_ stateName: String) {
        HapticManager.shared.lightImpact()
        selectedState = stateName
    }
    
    func proceedToNext() {
        guard let selected = selectedState else { return }
        UserDefaults.standard.set(selected, forKey: "selectedState")
        onNext()
    }
    
    func goBack() {
        onBack()
    }
    
    // MARK: - Dialog Title Logic
    var dialogMessageKey: String {
        guard let selected = selectedState, !selected.isEmpty else {
            return "state_selection_title_general"
        }
        // Keep diacritics as in localization keys (e.g., thüringen, baden_württemberg)
        let normalized = selected
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
        let key = "state_\(normalized)"
        return (key.localized != key) ? key : "state_selection_title_general"
    }
}


