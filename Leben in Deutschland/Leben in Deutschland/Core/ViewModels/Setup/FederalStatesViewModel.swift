//
//  FederalStatesViewModel.swift
//  Leben in Deutschland
//
//  Manages federal state selection and confirmation logic
//

import Foundation
import Combine

// MARK: - Federal States ViewModel
@MainActor
class FederalStatesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var showStateChangeWarning = false
    @Published var pendingStateChange: String?
    @Published var selectedState: String?
    private var originalState: String?
    
    // MARK: - Data
    let states = FederalStateModel.allStates
    
    // MARK: - Public Methods
    
    func initializeState(from stateManager: StateManager) {
        originalState = stateManager.selectedState
        selectedState = originalState
        pendingStateChange = nil
        showStateChangeWarning = false
    }
    
    /// Handles state selection with confirmation if needed
    func handleStateSelection(_ newState: String, stateManager: StateManager, onDismiss: @escaping () -> Void) {
        HapticManager.shared.lightImpact()
        selectedState = newState
        
        // If no state is currently selected or it's the same state, change directly
        if originalState == nil || originalState == newState {
            stateManager.setSelectedState(newState)
            originalState = newState
            onDismiss()
        } else {
            // Show confirmation dialog
            pendingStateChange = newState
            showStateChangeWarning = true
        }
    }
    
    /// Cancels state change confirmation
    func cancelStateChange() {
        HapticManager.shared.lightImpact()
        showStateChangeWarning = false
        pendingStateChange = nil
        selectedState = originalState
    }
    
    /// Confirms state change and clears progress
    func confirmStateChange(stateManager: StateManager, onDismiss: @escaping () -> Void) {
        HapticManager.shared.heavyImpact()
        
        // TODO: Clear statistics when managers are implemented
        // - answersManager.clearAnswers()
        // - spacedRepetitionManager.resetStatistics()
        // - favoritesManager.clearFavorites()
        
        // Clear user progress
        clearUserProgress()
        
        // Update the state
        if let newState = pendingStateChange {
            stateManager.setSelectedState(newState)
            originalState = newState
            selectedState = newState
        }
        
        showStateChangeWarning = false
        pendingStateChange = nil
        
        // Dismiss after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
    
    // MARK: - Private Methods
    
    /// Clears user progress from UserDefaults
    private func clearUserProgress() {
        let keysToRemove = [
            "FavoriteQuestions",
            "UserAnswers",
            "LearningModeAnswers",
            "quiz_progress_current_question",
            "quiz_progress_user_answers",
            "quiz_progress_checked_questions",
            "QuestionStatistics",
            "eagleProgress"
        ]
        
        keysToRemove.forEach { key in
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
