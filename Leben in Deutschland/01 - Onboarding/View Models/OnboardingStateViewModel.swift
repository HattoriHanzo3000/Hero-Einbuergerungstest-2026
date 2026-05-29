import Foundation
import SwiftUI
import Combine

// MARK: - Onboarding State ViewModel
@MainActor
class OnboardingStateViewModel: ObservableObject {
    @Published var selectedState: String?
    @Published var showDialog: Bool = false
    
    /// Header message: no-selection prompt vs slogan when selected
    var dialogMessageKey: String {
        guard let selectedState, let sloganKey = Self.stateSloganKeys[selectedState] else {
            return "choose_federal_state"
        }
        return sloganKey
    }
    
    let languageManager: LanguageManager
    private let preferences: OnboardingPreferences
    /// Propagates onboarding selections to the shared state manager.
    private let stateManager: StateManager?
    private let onNext: (() -> Void)?
    private let onBack: (() -> Void)?
    
    private static let stateSloganKeys: [String: String] = [
        "Baden-Württemberg": "state_baden_württemberg",
        "Bayern": "state_bayern",
        "Berlin": "state_berlin",
        "Brandenburg": "state_brandenburg",
        "Bremen": "state_bremen",
        "Hamburg": "state_hamburg",
        "Hessen": "state_hessen",
        "Mecklenburg-Vorpommern": "state_mecklenburg_vorpommern",
        "Niedersachsen": "state_niedersachsen",
        "Nordrhein-Westfalen": "state_nordrhein_westfalen",
        "Rheinland-Pfalz": "state_rheinland_pfalz",
        "Saarland": "state_saarland",
        "Sachsen": "state_sachsen",
        "Sachsen-Anhalt": "state_sachsen_anhalt",
        "Schleswig-Holstein": "state_schleswig_holstein",
        "Thüringen": "state_thüringen"
    ]
    
    init(
        languageManager: LanguageManager,
        preferences: OnboardingPreferences? = nil,
        stateManager: StateManager? = nil,
        onNext: (() -> Void)? = nil,
        onBack: (() -> Void)? = nil
    ) {
        self.languageManager = languageManager
        self.preferences = preferences ?? OnboardingPreferences.shared
        self.stateManager = stateManager
        self.onNext = onNext
        self.onBack = onBack
    }
    
    func setupInitialState() {
        // Only restore when user had previously selected (returning from a later step)
        if let savedState = preferences.selectedState {
            selectedState = savedState
            stateManager?.setSelectedState(savedState)
        } else {
            selectedState = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + OnboardingConstants.dialogDelay) {
            self.showDialog = true
        }
    }

    func selectState(_ state: String) {
        selectedState = state
        preferences.selectedState = state
        stateManager?.setSelectedState(state)
        showDialog = true
    }
    
    func proceedToNext() { onNext?() }
    func goBack() { onBack?() }
}
