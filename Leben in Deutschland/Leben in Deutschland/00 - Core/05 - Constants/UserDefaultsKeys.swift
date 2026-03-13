//
//  UserDefaultsKeys.swift
//  Leben in Deutschland
//
//  Shared keys for UserDefaults to avoid drift between StateManager and OnboardingPreferences.
//

import Foundation

enum UserDefaultsKeys {
    // MARK: - Settings & Preferences
    static let selectedState = "selectedState"
    static let vibrationEnabled = "vibration_enabled"
    static let soundEnabled = "sound_enabled"
    static let appearance = "app_appearance"

    // MARK: - Progress & Learning
    static let questionStatistics = "QuestionStatistics"
    static let learningAnswers = "learning_mode_answers"
    static let favoriteQuestionIds = "favoriteQuestionIds"
    static let selectedTestDate = "selectedTestDate"

    // MARK: - All Questions
    /// Last viewed question index in All Questions mode (0-based).
    static let allQuestionsCurrentIndex = "all_questions_current_index"

    /// When true, the Smart Learning disclaimer is not shown again.
    static let spacedRepetitionDisclaimerDismissed = "spaced_repetition_disclaimer_dismissed"

    /// When true, the All Questions disclaimer is not shown again.
    static let allQuestionsDisclaimerDismissed = "all_questions_disclaimer_dismissed"

    /// When true, the Learn by Topics disclaimer is not shown again.
    static let learnByTopicsDisclaimerDismissed = "learn_by_topics_disclaimer_dismissed"

    /// When true, the Favorites disclaimer is not shown again.
    static let favoritesDisclaimerDismissed = "favorites_disclaimer_dismissed"

    /// When true, the Test Simulation disclaimer is not shown again.
    static let testSimulationDisclaimerDismissed = "test_simulation_disclaimer_dismissed"

    // MARK: - Categories View
    static let categoriesExpanded = "categories_expanded_categories"

    /// Prefix for Learning mode position keys. Full key: "\(subcategoryPositionPrefix)\(subcategoryName)"
    static let subcategoryPositionPrefix = "subcategory_position_"
}
