//
//  MigrationManager.swift
//  Leben in Deutschland
//
//  One-time import of legacy UserDefaults progress into SwiftData. Cloud data wins on conflicts.
//  Created: 11.06.26.
//

import Foundation
import SwiftData

enum MigrationManager {
    static let questionStatisticsMigrationCompletedKey = "hasMigratedQuestionStatisticsToSwiftDataV1"
    static let learningAnswersMigrationCompletedKey = "hasMigratedLearningAnswersToSwiftDataV1"
    static let favoritesMigrationCompletedKey = "hasMigratedFavoritesToSwiftDataV1"
    static let userProfileMigrationCompletedKey = "hasMigratedUserProfileToSwiftDataV1"

    static func resetProgressMigrationFlags(using defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: questionStatisticsMigrationCompletedKey)
        defaults.removeObject(forKey: learningAnswersMigrationCompletedKey)
        defaults.removeObject(forKey: favoritesMigrationCompletedKey)
        defaults.removeObject(forKey: userProfileMigrationCompletedKey)
    }

    /// Migrates local-only `UserDefaults` progress into CloudKit-backed SwiftData (once per data type).
    @MainActor
    static func migrateLegacyUserDefaultsProgressToSwiftDataIfNeeded(
        context: ModelContext,
        defaults: UserDefaults = .standard
    ) {
        migrateUserProfileFromUserDefaultsIfNeeded(context: context, defaults: defaults)
        migrateQuestionStatisticsFromUserDefaultsIfNeeded(context: context, defaults: defaults)
        migrateLearningAnswersFromUserDefaultsIfNeeded(context: context, defaults: defaults)
        migrateFavoritesFromUserDefaultsIfNeeded(context: context, defaults: defaults)
    }

    // MARK: - User profile

    @MainActor
    private static func migrateUserProfileFromUserDefaultsIfNeeded(
        context: ModelContext,
        defaults: UserDefaults
    ) {
        guard !defaults.bool(forKey: userProfileMigrationCompletedKey) else { return }

        if UserProgressProfile.fetchExistingSingleton(in: context) != nil {
            markMigrationComplete(key: userProfileMigrationCompletedKey, defaults: defaults)
            return
        }

        let federalState = legacyFederalState(defaults: defaults)
        let legacyTest = legacyTestDate(defaults: defaults)
        let profile = UserProgressProfile(
            activeFederalState: federalState,
            testDate: legacyTest.date,
            testDateDontKnow: legacyTest.dontKnow,
            lastUpdated: Date()
        )
        context.insert(profile)

        persistMigration(key: userProfileMigrationCompletedKey, context: context, defaults: defaults)
    }

    // MARK: - Question statistics

    @MainActor
    private static func migrateQuestionStatisticsFromUserDefaultsIfNeeded(
        context: ModelContext,
        defaults: UserDefaults
    ) {
        guard !defaults.bool(forKey: questionStatisticsMigrationCompletedKey) else { return }

        guard let data = defaults.data(forKey: UserDefaultsKeys.questionStatistics),
              let decoded = try? JSONDecoder().decode([String: QuestionStatisticsModel].self, from: data)
        else {
            markMigrationComplete(key: questionStatisticsMigrationCompletedKey, defaults: defaults)
            return
        }

        let federalState = legacyFederalState(defaults: defaults)
        for (questionId, stats) in decoded {
            let recordId = ProgressRecordID.make(federalState: federalState, questionId: questionId)
            guard !questionStatisticsExists(recordId: recordId, in: context) else {
                continue
            }
            context.insert(QuestionStatisticsRecord(
                federalState: federalState,
                questionId: questionId,
                showCount: stats.showCount,
                correctCount: stats.correctCount,
                incorrectCount: stats.incorrectCount,
                lastShownDate: stats.lastShownDate,
                nextReviewDate: stats.nextReviewDate,
                interval: stats.interval,
                masteryLevel: stats.masteryLevel,
                consecutiveCorrect: stats.consecutiveCorrect,
                lastAnswerWasCorrect: stats.lastAnswerWasCorrect
            ))
        }

        persistMigration(key: questionStatisticsMigrationCompletedKey, context: context, defaults: defaults)
    }

    // MARK: - Learning answers

    @MainActor
    private static func migrateLearningAnswersFromUserDefaultsIfNeeded(
        context: ModelContext,
        defaults: UserDefaults
    ) {
        guard !defaults.bool(forKey: learningAnswersMigrationCompletedKey) else { return }

        guard let data = defaults.data(forKey: UserDefaultsKeys.learningAnswers),
              let decoded = try? JSONDecoder().decode([String: Int].self, from: data)
        else {
            markMigrationComplete(key: learningAnswersMigrationCompletedKey, defaults: defaults)
            return
        }

        let federalState = legacyFederalState(defaults: defaults)
        for (questionId, answerIndex) in decoded {
            let recordId = ProgressRecordID.make(federalState: federalState, questionId: questionId)
            guard !learningAnswerExists(recordId: recordId, in: context) else {
                continue
            }
            context.insert(LearningAnswerRecord(
                federalState: federalState,
                questionId: questionId,
                answerIndex: answerIndex
            ))
        }

        persistMigration(key: learningAnswersMigrationCompletedKey, context: context, defaults: defaults)
    }

    // MARK: - Favorites

    @MainActor
    private static func migrateFavoritesFromUserDefaultsIfNeeded(
        context: ModelContext,
        defaults: UserDefaults
    ) {
        guard !defaults.bool(forKey: favoritesMigrationCompletedKey) else { return }

        guard let ids = defaults.array(forKey: UserDefaultsKeys.favoriteQuestionIds) as? [String] else {
            markMigrationComplete(key: favoritesMigrationCompletedKey, defaults: defaults)
            return
        }

        let federalState = legacyFederalState(defaults: defaults)
        for questionId in ids {
            let recordId = ProgressRecordID.make(federalState: federalState, questionId: questionId)
            guard !favoriteQuestionExists(recordId: recordId, in: context) else {
                continue
            }
            context.insert(FavoriteQuestion(federalState: federalState, questionId: questionId))
        }

        persistMigration(key: favoritesMigrationCompletedKey, context: context, defaults: defaults)
    }

    // MARK: - Helpers

    @MainActor
    private static func questionStatisticsExists(recordId: String, in context: ModelContext) -> Bool {
        let id = recordId
        var descriptor = FetchDescriptor<QuestionStatisticsRecord>(
            predicate: #Predicate<QuestionStatisticsRecord> { $0.recordId == id }
        )
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor).first) != nil
    }

    @MainActor
    private static func learningAnswerExists(recordId: String, in context: ModelContext) -> Bool {
        let id = recordId
        var descriptor = FetchDescriptor<LearningAnswerRecord>(
            predicate: #Predicate<LearningAnswerRecord> { $0.recordId == id }
        )
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor).first) != nil
    }

    @MainActor
    private static func favoriteQuestionExists(recordId: String, in context: ModelContext) -> Bool {
        let id = recordId
        var descriptor = FetchDescriptor<FavoriteQuestion>(
            predicate: #Predicate<FavoriteQuestion> { $0.recordId == id }
        )
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor).first) != nil
    }

    private static func legacyFederalState(defaults: UserDefaults) -> String {
        OnboardingPreferences.shared.selectedState
            ?? defaults.string(forKey: UserDefaultsKeys.selectedState)
            ?? StateManager.shared.selectedState
            ?? FederalStateModel.allStates.first?.name
            ?? "Berlin"
    }

    private static func legacyTestDate(defaults: UserDefaults) -> (date: Date?, dontKnow: Bool) {
        let onboardingDate = OnboardingPreferences.shared.testDate
        let selectedTestDate = defaults.object(forKey: UserDefaultsKeys.selectedTestDate) as? Date
        let date = onboardingDate ?? selectedTestDate
        let dontKnow = date == nil ? OnboardingPreferences.shared.testDateDontKnow : false
        return (date, dontKnow)
    }

    @MainActor
    private static func persistMigration(
        key: String,
        context: ModelContext,
        defaults: UserDefaults
    ) {
        do {
            try context.save()
            markMigrationComplete(key: key, defaults: defaults)
        } catch {
            // Leave flag unset so a future launch can retry after e.g. CloudKit/local store issues.
        }
    }

    private static func markMigrationComplete(key: String, defaults: UserDefaults) {
        defaults.set(true, forKey: key)
    }
}
