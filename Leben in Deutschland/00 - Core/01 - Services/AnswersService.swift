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
    @discardableResult
    func saveAnswer(_ answerIndex: Int, for questionId: String) -> Bool {
        guard persistAnswer(questionId: questionId, answerIndex: answerIndex) else { return false }
        learningAnswers[questionId] = answerIndex
        return true
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
    @discardableResult
    func clearAnswer(for questionId: String) -> Bool {
        guard deleteAnswer(questionId: questionId) else { return false }
        learningAnswers.removeValue(forKey: questionId)
        return true
    }

    /// Clear all answers (used in settings reset)
    func clearAllAnswers() {
        guard deleteAllAnswersFromStore() else { return }
        learningAnswers.removeAll()
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.learningAnswers)
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

    @discardableResult
    private func persistAnswer(questionId: String, answerIndex: Int) -> Bool {
        guard let context = modelContext, !activeFederalState.isEmpty else { return false }

        let recordId = ProgressRecordID.make(federalState: activeFederalState, questionId: questionId)
        let id = recordId
        var descriptor = FetchDescriptor<LearningAnswerRecord>(
            predicate: #Predicate<LearningAnswerRecord> { $0.recordId == id }
        )
        descriptor.fetchLimit = 1

        do {
            if let existing = try context.fetch(descriptor).first {
                existing.answerIndex = answerIndex
            } else {
                context.insert(LearningAnswerRecord(
                    federalState: activeFederalState,
                    questionId: questionId,
                    answerIndex: answerIndex
                ))
            }
            try context.save()
            return true
        } catch {
            return false
        }
    }

    @discardableResult
    private func deleteAnswer(questionId: String) -> Bool {
        guard let context = modelContext, !activeFederalState.isEmpty else { return false }

        let recordId = ProgressRecordID.make(federalState: activeFederalState, questionId: questionId)
        let id = recordId
        var descriptor = FetchDescriptor<LearningAnswerRecord>(
            predicate: #Predicate<LearningAnswerRecord> { $0.recordId == id }
        )
        descriptor.fetchLimit = 1

        do {
            guard let existing = try context.fetch(descriptor).first else { return true }
            context.delete(existing)
            try context.save()
            return true
        } catch {
            return false
        }
    }

    @discardableResult
    private func deleteAllAnswersFromStore() -> Bool {
        guard let context = modelContext else { return true }

        do {
            try LearningAnswerRecord.deleteAll(in: context)
            return true
        } catch {
            return false
        }
    }
}
