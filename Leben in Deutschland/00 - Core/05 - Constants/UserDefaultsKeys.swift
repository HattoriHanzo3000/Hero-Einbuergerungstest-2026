//
//  UserDefaultsKeys.swift
//  Leben in Deutschland
//
//  Shared keys for UserDefaults to avoid drift between StateManager and OnboardingPreferences.
//

import Foundation

enum UserDefaultsKeys {
    // MARK: - Settings & Preferences
    /// Date of first app launch. Used for 3-day Launch Offer countdown.
    static let firstLaunchDate = "first_launch_date"
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

    /// Highest eagle stage the user has seen (raw Int). Used for level-up splash.
    static let eagleLastSeenStage = "eagle_last_seen_stage"

    // MARK: - Categories View
    static let categoriesExpanded = "categories_expanded_categories"

    /// Prefix for Learning mode position keys. Full key: "\(subcategoryPositionPrefix)\(subcategoryName)"
    static let subcategoryPositionPrefix = "subcategory_position_"

    // MARK: - Question feedback
    /// Recent report submission timestamps (TimeInterval) for client-side rate limiting.
    static let questionFeedbackSubmissionTimestamps = "question_feedback_submission_timestamps"

    // MARK: - Freemium Usage
    static let freemiumSmartLearningAnswerCount = "freemium_smart_learning_answer_count"
    static let freemiumTestSimulationsStartedCount = "freemium_test_simulations_started_count"
    static let lastKnownPremiumState = "lastKnownPremiumState"

    // MARK: - Debug (DEBUG builds only)
    /// When set, overrides pro status. "true"/"false" or absent = use real.
    static let debugSimulatePro = "debug_simulate_pro"
    /// Overrides readiness percentage. 0 = none, 10/30/50/100 = override.
    static let debugReadinessPercent = "debug_readiness_percent"
}
