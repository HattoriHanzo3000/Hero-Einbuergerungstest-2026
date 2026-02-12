import Foundation
import SwiftUI
import Combine

// MARK: - State Manager
@MainActor
class StateManager: ObservableObject {
    static let shared = StateManager()
    
    @Published var selectedState: String?
    
    private init() {
        loadSavedState()
    }
    
    // MARK: - State Management
    
    func setSelectedState(_ state: String) {
        guard selectedState != state else { return }
        objectWillChange.send()
        selectedState = state
        UserDefaults.standard.set(state, forKey: UserDefaultsKeys.selectedState)
    }
    
    func clearSelectedState() {
        selectedState = nil
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.selectedState)
    }
    
    // MARK: - Private Methods
    
    /// Loads persisted state. Returns nil when none exists (user has not selected yet).
    private func loadSavedState() {
        selectedState = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedState)
    }
}
