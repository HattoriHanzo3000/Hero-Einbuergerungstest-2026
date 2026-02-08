import Foundation
import Combine

// MARK: - Spaced Repetition Managing
protocol SpacedRepetitionManaging: AnyObject {
    func questionsForSession(from questions: [QuestionModel], limit: Int) -> [QuestionModel]
    func recordAnswer(for questionId: String, isCorrect: Bool)
    /// Records that the user reset/cleared their answer for this question (counts as negative for readiness).
    func recordReset(for questionId: String)
    func readinessPercentage(totalQuestions: Int) -> Int
    func progressBuckets(totalQuestions: Int) -> (familiar: Int, reinforced: Int, mastered: Int, expert: Int, total: Int)
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

    /// Records a reset (user cleared answer); counts as negative for readiness.
    func recordReset(for questionId: String) {
        guard var stats = statistics[questionId] else { return }
        stats.applyReset()
        statistics[questionId] = stats
        saveStatistics()
    }

    // MARK: - Progress (readiness based on correct count only: 1→0.25, 2→0.5, 3→0.75, 4+→1.0)
    func readinessPercentage(totalQuestions: Int) -> Int {
        guard totalQuestions > 0 else { return 0 }
        let totalContribution = statistics.values.reduce(0.0) { sum, stats in
            sum + Self.readinessContribution(correctCount: stats.correctCount)
        }
        let percentage = totalContribution / Double(totalQuestions) * 100
        return min(max(Int(percentage.rounded()), 0), 100)
    }

    private static func readinessContribution(correctCount: Int) -> Double {
        switch correctCount {
        case 0: return 0.0
        case 1: return 0.25
        case 2: return 0.5
        case 3: return 0.75
        default: return 1.0  // 4+ correct = full credit
        }
    }
    
    func progressBuckets(totalQuestions: Int) -> (familiar: Int, reinforced: Int, mastered: Int, expert: Int, total: Int) {
        let familiar = statistics.values.filter { $0.correctCount == 1 }.count
        let reinforced = statistics.values.filter { $0.correctCount == 2 }.count
        let mastered = statistics.values.filter { $0.correctCount == 3 }.count
        let expert = statistics.values.filter { $0.correctCount >= 4 }.count
        return (familiar, reinforced, mastered, expert, totalQuestions)
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

