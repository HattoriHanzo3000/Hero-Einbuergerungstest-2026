import Foundation
import Combine
import SwiftData

// MARK: - Spaced Repetition Managing
protocol SpacedRepetitionManaging: AnyObject {
    func questionsForSession(from questions: [QuestionModel], limit: Int) -> [QuestionModel]
    func recordAnswer(for questionId: String, isCorrect: Bool)
    /// Records that the user reset/cleared their answer for this question (counts as negative for readiness).
    func recordReset(for questionId: String)
    func readinessPercentage(totalQuestions: Int) -> Int
    func progressBuckets(totalQuestions: Int) -> (familiar: Int, reinforced: Int, mastered: Int, expert: Int, total: Int)
    /// Clears all statistics in memory and persistence (e.g. app reset).
    func clearAllStatistics()
}

// MARK: - Spaced Repetition Manager
@MainActor
final class SpacedRepetitionManager: ObservableObject, SpacedRepetitionManaging {
    static let shared = SpacedRepetitionManager()

    @Published private(set) var statistics: [String: QuestionStatisticsModel] = [:]

    private let defaults: UserDefaults
    private let calendar = Calendar.current
    private var modelContext: ModelContext?
    private var activeFederalState: String = ""

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func bind(modelContext: ModelContext, activeFederalState: String) {
        self.modelContext = modelContext
        self.activeFederalState = activeFederalState
        reloadFromStore()
    }

    func reloadForFederalState(_ state: String) {
        activeFederalState = state
        reloadFromStore()
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
        persistRecord(stats)
    }

    private func computeDaysUntilTest() -> Int {
        let testDate = OnboardingPreferences.shared.testDate
            ?? defaults.object(forKey: UserDefaultsKeys.selectedTestDate) as? Date
        guard let date = testDate else { return LayoutMetrics.maxHorizonDays }
        let days = calendar.dateComponents([.day], from: Date(), to: date).day ?? 0
        return min(max(0, days), LayoutMetrics.maxHorizonDays)
    }

    /// Records a reset (user cleared answer); counts as negative for readiness.
    func recordReset(for questionId: String) {
        guard var stats = statistics[questionId] else { return }
        stats.applyReset()
        statistics[questionId] = stats
        persistRecord(stats)
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

    func clearAllStatistics() {
        statistics = [:]
        defaults.removeObject(forKey: UserDefaultsKeys.questionStatistics)
        guard let context = modelContext else { return }
        try? QuestionStatisticsRecord.deleteAll(in: context)
    }
}

// MARK: - Persistence
private extension SpacedRepetitionManager {
    func reloadFromStore() {
        guard let context = modelContext, !activeFederalState.isEmpty else {
            statistics = [:]
            return
        }

        let state = activeFederalState
        let descriptor = FetchDescriptor<QuestionStatisticsRecord>(
            predicate: #Predicate<QuestionStatisticsRecord> { $0.federalState == state }
        )
        let rows = (try? context.fetch(descriptor)) ?? []
        var loaded: [String: QuestionStatisticsModel] = [:]
        for row in rows {
            loaded[row.questionId] = QuestionStatisticsModel(record: row)
        }
        statistics = loaded
    }

    func persistRecord(_ stats: QuestionStatisticsModel) {
        guard let context = modelContext, !activeFederalState.isEmpty else { return }

        let recordId = ProgressRecordID.make(federalState: activeFederalState, questionId: stats.questionId)
        let id = recordId
        var descriptor = FetchDescriptor<QuestionStatisticsRecord>(
            predicate: #Predicate<QuestionStatisticsRecord> { $0.recordId == id }
        )
        descriptor.fetchLimit = 1

        if let existing = try? context.fetch(descriptor).first {
            existing.apply(from: stats)
        } else {
            context.insert(QuestionStatisticsRecord(
                federalState: activeFederalState,
                questionId: stats.questionId,
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
        try? context.save()
    }
}
