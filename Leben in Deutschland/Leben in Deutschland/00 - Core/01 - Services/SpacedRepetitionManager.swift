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
        
        // Bucketed selection for diversity (avoid ID clustering)
        enum Bucket { case new, hard, medium, easy }
        
        func bucket(for question: QuestionModel) -> Bucket {
            guard let stats = statistics[question.id] else { return .new }
            if stats.correctCount >= 4 { return .easy }
            if stats.accuracy < 0.65 { return .hard }
            return .medium
        }
        
        func comparePriority(_ l: QuestionModel, _ r: QuestionModel) -> Bool {
            let lStats = statistics[l.id]
            let rStats = statistics[r.id]
            let lDate = lStats?.nextReviewDate ?? .distantPast
            let rDate = rStats?.nextReviewDate ?? .distantPast
            if lDate != rDate { return lDate < rDate }
            return (lStats?.showCount ?? 0) < (rStats?.showCount ?? 0)
        }
        
        let new = readyQuestions.filter { bucket(for: $0) == .new }.shuffled()
        let hard = readyQuestions.filter { bucket(for: $0) == .hard }
            .sorted(by: comparePriority).shuffled()
        let medium = readyQuestions.filter { bucket(for: $0) == .medium }
            .sorted(by: comparePriority).shuffled()
        let easy = readyQuestions.filter { bucket(for: $0) == .easy }
            .sorted(by: comparePriority).shuffled()
        
        // Target mix: 5 Hard, 3 Medium, 2 New, 1 Easy (for limit 12)
        let targetHard = min(5, limit)
        let targetMedium = min(3, max(0, limit - targetHard))
        let targetNew = min(2, max(0, limit - targetHard - targetMedium))
        let targetEasy = min(1, max(0, limit - targetHard - targetMedium - targetNew))
        
        var session: [QuestionModel] = []
        var usedIds = Set<String>()
        
        func add(_ q: QuestionModel) {
            guard !usedIds.contains(q.id) else { return }
            usedIds.insert(q.id)
            session.append(q)
        }
        
        for q in hard.prefix(targetHard) { add(q) }
        for q in medium.prefix(targetMedium) { add(q) }
        for q in new.prefix(targetNew) { add(q) }
        for q in easy.prefix(targetEasy) { add(q) }
        
        // Backfill from remaining buckets in round-robin
        var h = targetHard, m = targetMedium, n = targetNew, e = targetEasy
        var bucketIndex = 0
        while session.count < limit {
            var didAdd = false
            switch bucketIndex {
            case 0:
                if h < hard.count, !usedIds.contains(hard[h].id) { add(hard[h]); h += 1; didAdd = true }
            case 1:
                if m < medium.count, !usedIds.contains(medium[m].id) { add(medium[m]); m += 1; didAdd = true }
            case 2:
                if n < new.count, !usedIds.contains(new[n].id) { add(new[n]); n += 1; didAdd = true }
            case 3:
                if e < easy.count, !usedIds.contains(easy[e].id) { add(easy[e]); e += 1; didAdd = true }
            default: break
            }
            bucketIndex = (bucketIndex + 1) % 4
            if !didAdd && h >= hard.count && m >= medium.count && n >= new.count && e >= easy.count { break }
        }
        
        if session.count < limit {
            let unseen = questions.filter { statistics[$0.id] == nil }
            for q in unseen where session.count < limit && !usedIds.contains(q.id) {
                add(q)
            }
        }
        
        if session.count < limit {
            for q in questions where session.count < limit && !usedIds.contains(q.id) {
                add(q)
            }
        }
        
        return session
    }
    
    // MARK: - Recording
    func recordAnswer(for questionId: String, isCorrect: Bool) {
        let daysUntilTest = computeDaysUntilTest()
        var stats = statistics[questionId] ?? QuestionStatisticsModel(questionId: questionId)
        stats.registerAnswer(isCorrect: isCorrect, daysUntilTest: daysUntilTest)
        statistics[questionId] = stats
        saveStatistics()
    }
    
    private func computeDaysUntilTest() -> Int {
        let testDate = OnboardingPreferences.shared.testDate
            ?? defaults.object(forKey: "selectedTestDate") as? Date
        guard let date = testDate else { return LayoutMetrics.maxHorizonDays }
        let days = calendar.dateComponents([.day], from: Date(), to: date).day ?? 0
        return min(max(0, days), LayoutMetrics.maxHorizonDays)
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

