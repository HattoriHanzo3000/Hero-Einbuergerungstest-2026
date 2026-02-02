import Foundation

// MARK: - Home Statistics Providing
/// Abstraction that surfaces the learner’s spaced-repetition progress for the home screen.
protocol HomeStatisticsProviding {
    func loadStatistics() -> HomeStatisticsModel
}

// MARK: - Home Statistics Service
/// Reads persisted spaced-repetition metadata from `UserDefaults` and transforms it into `HomeStatisticsModel`.
final class HomeStatisticsService: HomeStatisticsProviding {
    private let defaults: UserDefaults
    private let statisticsKey = "QuestionStatistics"
    private let totalQuestions: Int
    
    init(
        defaults: UserDefaults = .standard,
        totalQuestions: Int = LayoutMetrics.totalFederalQuestions
    ) {
        self.defaults = defaults
        self.totalQuestions = totalQuestions
    }
    
    func loadStatistics() -> HomeStatisticsModel {
        guard let data = defaults.data(forKey: statisticsKey),
              let decodedStatistics = try? JSONDecoder().decode([String: QuestionStatisticRecord].self, from: data)
        else {
            // On first launch or when no statistics exist, return 0% readiness
            return HomeStatisticsModel(
                readinessPercentage: 0,
                wrong: 0,
                familiar: 0,
                reinforced: 0,
                mastered: 0,
                totalQuestions: totalQuestions
            )
        }
        
        let statistics = decodedStatistics.values
        let wrong = statistics.filter { ($0.correctCount ?? 0) == 0 && ($0.showCount ?? 0) > 0 }.count
        let familiar = statistics.filter { $0.correctCount == 1 && ($0.showCount ?? 0) > 0 }.count
        let reinforced = statistics.filter { $0.correctCount == 2 && ($0.showCount ?? 0) > 0 }.count
        let mastered = statistics.filter { ($0.correctCount ?? 0) >= 3 }.count
        
        let weightedScore = familiar + (reinforced * 2) + (mastered * 3)
        let maxScore = totalQuestions * 3
        let readinessFromStats = maxScore > 0
            ? Int((Double(weightedScore) / Double(maxScore)) * 100)
            : 0
        
        return HomeStatisticsModel(
            readinessPercentage: min(max(readinessFromStats, 0), 100),
            wrong: wrong,
            familiar: familiar,
            reinforced: reinforced,
            mastered: mastered,
            totalQuestions: totalQuestions
        )
    }
}

// MARK: - Question Statistic Record
/// Partial representation of the legacy spaced-repetition record stored in `UserDefaults`.
private struct QuestionStatisticRecord: Codable {
    let questionId: String?
    let showCount: Int?
    let correctCount: Int?
    let incorrectCount: Int?
    let lastShownDate: Date?
    let nextReviewDate: Date?
    let interval: Int?
    let masteryLevel: Int?
    let consecutiveCorrect: Int?
}

