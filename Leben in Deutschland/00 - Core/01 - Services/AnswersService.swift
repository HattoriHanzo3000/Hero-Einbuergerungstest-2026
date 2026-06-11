//
//  AnswersService.swift
//  Leben in Deutschland
//
//  Service for persisting and managing user answers
//

import Foundation
import Combine
import SwiftData

// MARK: - Answers Service
@MainActor
class AnswersService: ObservableObject {
    @Published private(set) var learningAnswers: [String: Int] = [:]

    // MARK: - Singleton
    static let shared = AnswersService()

    private var modelContext: ModelContext?
    private var activeFederalState: String = ""

    private init() {}

    func bind(modelContext: ModelContext, activeFederalState: String) {
        self.modelContext = modelContext
        self.activeFederalState = activeFederalState
        reloadFromStore()
    }

    func reloadForFederalState(_ state: String) {
        activeFederalState = state
        reloadFromStore()
    }

    // MARK: - Learning Mode Answers

    /// Save an answer for a question in learning mode
    func saveAnswer(_ answerIndex: Int, for questionId: String) {
        learningAnswers[questionId] = answerIndex
        persistAnswer(questionId: questionId, answerIndex: answerIndex)
    }

    /// Get saved answer for a question
    func getAnswer(for questionId: String) -> Int? {
        return learningAnswers[questionId]
    }

    /// Check if a question has been answered
    func hasAnswer(for questionId: String) -> Bool {
        return learningAnswers[questionId] != nil
    }

    /// Clear answer for a specific question
    func clearAnswer(for questionId: String) {
        learningAnswers.removeValue(forKey: questionId)
        deleteAnswer(questionId: questionId)
    }

    /// Clear all answers (used in settings reset)
    func clearAllAnswers() {
        learningAnswers.removeAll()
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.learningAnswers)
        guard let context = modelContext else { return }
        try? LearningAnswerRecord.deleteAll(in: context)
    }

    /// Get count of answered questions
    func getAnsweredCount() -> Int {
        return learningAnswers.count
    }

    /// Calculate completion percentage for a subcategory
    func getCompletionPercentage(for subcategory: SubcategoryModel) -> Double {
        guard !subcategory.questions.isEmpty else { return 0.0 }

        let answeredCount = subcategory.questions.filter { question in
            hasAnswer(for: question.id)
        }.count

        return Double(answeredCount) / Double(subcategory.questions.count)
    }

    /// Get count of answered questions for a subcategory
    func getAnsweredCount(for subcategory: SubcategoryModel) -> Int {
        return subcategory.questions.filter { question in
            hasAnswer(for: question.id)
        }.count
    }

    // MARK: - Private Methods

    private func reloadFromStore() {
        guard let context = modelContext, !activeFederalState.isEmpty else {
            learningAnswers = [:]
            return
        }

        let state = activeFederalState
        let descriptor = FetchDescriptor<LearningAnswerRecord>(
            predicate: #Predicate<LearningAnswerRecord> { $0.federalState == state }
        )
        let rows = (try? context.fetch(descriptor)) ?? []
        var loaded: [String: Int] = [:]
        for row in rows {
            loaded[row.questionId] = row.answerIndex
        }
        learningAnswers = loaded
    }

    private func persistAnswer(questionId: String, answerIndex: Int) {
        guard let context = modelContext, !activeFederalState.isEmpty else { return }

        let recordId = ProgressRecordID.make(federalState: activeFederalState, questionId: questionId)
        let id = recordId
        var descriptor = FetchDescriptor<LearningAnswerRecord>(
            predicate: #Predicate<LearningAnswerRecord> { $0.recordId == id }
        )
        descriptor.fetchLimit = 1

        if let existing = try? context.fetch(descriptor).first {
            existing.answerIndex = answerIndex
        } else {
            context.insert(LearningAnswerRecord(
                federalState: activeFederalState,
                questionId: questionId,
                answerIndex: answerIndex
            ))
        }
        try? context.save()
    }

    private func deleteAnswer(questionId: String) {
        guard let context = modelContext, !activeFederalState.isEmpty else { return }

        let recordId = ProgressRecordID.make(federalState: activeFederalState, questionId: questionId)
        let id = recordId
        var descriptor = FetchDescriptor<LearningAnswerRecord>(
            predicate: #Predicate<LearningAnswerRecord> { $0.recordId == id }
        )
        descriptor.fetchLimit = 1
        if let existing = try? context.fetch(descriptor).first {
            context.delete(existing)
            try? context.save()
        }
    }
}
