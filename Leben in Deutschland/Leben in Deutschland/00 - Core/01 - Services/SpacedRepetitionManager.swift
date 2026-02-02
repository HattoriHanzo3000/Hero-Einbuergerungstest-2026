import Foundation
import Combine

// MARK: - Spaced Repetition Managing
protocol SpacedRepetitionManaging: AnyObject {
    func questionsForSession(from questions: [QuestionModel], limit: Int) -> [QuestionModel]
    func recordAnswer(for questionId: String, isCorrect: Bool)
    func readinessPercentage(totalQuestions: Int) -> Int
    func progressBuckets(totalQuestions: Int) -> (wrong: Int, familiar: Int, reinforced: Int, mastered: Int, total: Int)
}

// MARK: - Spaced Repetition Manager
final class SpacedRepetitionManager: ObservableObject, SpacedRepetitionManaging {
    static let shared = SpacedRepetitionManager()
    
    @Published private(set) var statistics: [String: QuestionStatisticsModel] = [:]
    
    private let statisticsKey = "QuestionStatistics"
    private let defaults: UserDefaults
    private let calendar = Calendar.current
    
    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        loadStatistics()
    }
    
    // MARK: - Session
    func questionsForSession(from questions: [QuestionModel], limit: Int = 20) -> [QuestionModel] {
        guard limit > 0 else { return [] }
        let today = Date()
        
        let readyQuestions = questions.filter { question in
            guard let stats = statistics[question.id] else { return true }
            guard let nextReview = stats.nextReviewDate else { return true }
            return nextReview <= today
        }
        
        let rankedReady = readyQuestions.sorted { lhs, rhs in
            let leftStats = statistics[lhs.id]
            let rightStats = statistics[rhs.id]
            let leftDifficulty = 1.0 - (leftStats?.accuracy ?? 0)
            let rightDifficulty = 1.0 - (rightStats?.accuracy ?? 0)
            if leftDifficulty == rightDifficulty {
                return (leftStats?.showCount ?? 0) < (rightStats?.showCount ?? 0)
            }
            return leftDifficulty > rightDifficulty
        }
        
        var session: [QuestionModel] = []
        session.append(contentsOf: rankedReady.prefix(limit))
        
        if session.count < limit {
            let unseenQuestions = questions.filter { statistics[$0.id] == nil }
            for question in unseenQuestions where !session.contains(where: { $0.id == question.id }) {
                session.append(question)
                if session.count == limit { break }
            }
        }
        
        if session.count < limit {
            for question in questions where !session.contains(where: { $0.id == question.id }) {
                session.append(question)
                if session.count == limit { break }
            }
        }
        
        return session
    }
    
    // MARK: - Recording
    func recordAnswer(for questionId: String, isCorrect: Bool) {
        var stats = statistics[questionId] ?? QuestionStatisticsModel(questionId: questionId)
        stats.registerAnswer(isCorrect: isCorrect)
        statistics[questionId] = stats
        saveStatistics()
    }
    
    // MARK: - Progress
    func readinessPercentage(totalQuestions: Int) -> Int {
        guard totalQuestions > 0 else { return 0 }
        let totalCorrect = statistics.values.reduce(0) { $0 + min($1.correctCount, 3) }
        let maxPossible = totalQuestions * 3
        guard maxPossible > 0 else { return 0 }
        let percentage = Double(totalCorrect) / Double(maxPossible) * 100
        return min(Int(percentage.rounded()), 100)
    }
    
    func progressBuckets(totalQuestions: Int) -> (wrong: Int, familiar: Int, reinforced: Int, mastered: Int, total: Int) {
        let wrong = statistics.values.filter { $0.correctCount == 0 && $0.showCount > 0 }.count
        let familiar = statistics.values.filter { $0.correctCount == 1 && $0.showCount > 0 }.count
        let reinforced = statistics.values.filter { $0.correctCount == 2 && $0.showCount > 0 }.count
        let mastered = statistics.values.filter { $0.correctCount >= 3 }.count
        return (wrong, familiar, reinforced, mastered, totalQuestions)
    }
}

// MARK: - Persistence
private extension SpacedRepetitionManager {
    func loadStatistics() {
        guard let data = defaults.data(forKey: statisticsKey) else {
            statistics = [:]
            return
        }
        if let decoded = try? JSONDecoder().decode([String: QuestionStatisticsModel].self, from: data) {
            statistics = decoded
        }
    }
    
    func saveStatistics() {
        if let data = try? JSONEncoder().encode(statistics) {
            defaults.set(data, forKey: statisticsKey)
        }
    }
}

