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

    // MARK: - Categories View
    static let categoriesExpanded = "categories_expanded_categories"

    /// Prefix for Learning mode position keys. Full key: "\(subcategoryPositionPrefix)\(subcategoryName)"
    static let subcategoryPositionPrefix = "subcategory_position_"
}
