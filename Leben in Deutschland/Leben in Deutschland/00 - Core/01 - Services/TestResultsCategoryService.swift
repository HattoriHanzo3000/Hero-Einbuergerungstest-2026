//
//  TestResultsCategoryService.swift
//  Leben in Deutschland
//
//  Computes per-category breakdown for test results (correct/total per category).
//

import Foundation

// MARK: - Category Stat
struct TestResultsCategoryStat {
    let name: String
    let correct: Int
    let total: Int
}

// MARK: - Test Results Category Service
enum TestResultsCategoryService {
    /// All categories with (correct, total), sorted by most correct first, then by localized name.
    static func computeBreakdown(
        questions: [TestQuestion],
        answers: [TestUserAnswer],
        languageCode: String
    ) -> [TestResultsCategoryStat] {
        let stats = buildPerCategoryStats(questions: questions, answers: answers)
        return stats.sorted { a, b in
            if a.correct != b.correct { return a.correct > b.correct }
            return a.name.localized(for: languageCode) < b.name.localized(for: languageCode)
        }
    }
    
    private static func buildPerCategoryStats(
        questions: [TestQuestion],
        answers: [TestUserAnswer]
    ) -> [TestResultsCategoryStat] {
        var byCategory: [String: (total: Int, correct: Int)] = [:]
        for answer in answers {
            guard let question = questions.first(where: { $0.id == answer.questionId }) else { continue }
            let cat = question.category
            var pair = byCategory[cat] ?? (0, 0)
            pair.total += 1
            if answer.isCorrect { pair.correct += 1 }
            byCategory[cat] = pair
        }
        return byCategory.map { TestResultsCategoryStat(name: $0.key, correct: $0.value.correct, total: $0.value.total) }
    }
}
