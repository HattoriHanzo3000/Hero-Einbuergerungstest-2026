import Foundation
import SwiftUI
import Combine

// MARK: - State Manager
@MainActor
class StateManager: ObservableObject {
    @Published var selectedState: String?
    
    init() {
        loadSavedState()
    }
    
    // MARK: - State Management
    
    func setSelectedState(_ state: String) {
        selectedState = state
        UserDefaults.standard.set(state, forKey: "selectedState")
    }
    
    func clearSelectedState() {
        selectedState = nil
        UserDefaults.standard.removeObject(forKey: "selectedState")
    }
    
    // MARK: - Private Methods
    
    private func loadSavedState() {
        // Load saved state, or default to "Berlin" if none exists
        selectedState = UserDefaults.standard.string(forKey: "selectedState") ?? "Berlin"
    }
}
