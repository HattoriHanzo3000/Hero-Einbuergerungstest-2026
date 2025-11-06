import Foundation
import SwiftUI
import Combine

// MARK: - Onboarding State ViewModel
@MainActor
class OnboardingStateViewModel: ObservableObject {
    @Published var selectedState: String?
    @Published var showDialog: Bool = false
    
    // Dialog message key for the header bubble
    var dialogMessageKey: String { "state_selection_title_general" }
    
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
        // Restore previously saved state if available
        if let savedState = preferences.selectedState {
            selectedState = savedState
        }
        // Show dialog with delay to match other onboarding screens
        DispatchQueue.main.asyncAfter(deadline: .now() + OnboardingConstants.dialogDelay) {
            self.showDialog = true
        }
    }

    func selectState(_ state: String) {
        selectedState = state
        preferences.selectedState = state
    }
    
    func proceedToNext() { onNext?() }
    func goBack() { onBack?() }
}
