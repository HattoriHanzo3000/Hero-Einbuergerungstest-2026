//
//  FederalStateProgressResetService.swift
//  Leben in Deutschland
//
//  Centralised cleanup for progress that depends on the selected federal state.
//

import Foundation

@MainActor
enum FederalStateProgressResetService {
    /// Removes persisted progress that becomes invalid after switching the federal state.
    /// - Parameter defaults: User defaults storage, injected for testing.
    static func reset(using defaults: UserDefaults = .standard) {
        let keysToRemove: [String] = [
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
            defaults.removeObject(forKey: key)
        }
    }
}


