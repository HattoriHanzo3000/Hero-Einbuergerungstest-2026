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
                familiar: 0,
                reinforced: 0,
                mastered: 0,
                expert: 0,
                totalQuestions: totalQuestions
            )
        }
        
        let statistics = decodedStatistics.values
        let familiar = statistics.filter { ($0.correctCount ?? 0) == 1 }.count
        let reinforced = statistics.filter { ($0.correctCount ?? 0) == 2 }.count
        let mastered = statistics.filter { ($0.correctCount ?? 0) == 3 }.count
        let expert = statistics.filter { ($0.correctCount ?? 0) >= 4 }.count
        
        // Readiness: 1→0.25, 2→0.5, 3→0.75, 4+→1.0 (100% only when all 310 have 4+)
        let totalContribution = statistics.reduce(0.0) { sum, record in
            let correctCount = record.correctCount ?? 0
            return sum + readinessContribution(correctCount: correctCount)
        }
        let readinessFromStats = Int((totalContribution / Double(totalQuestions)) * 100)
        
        return HomeStatisticsModel(
            readinessPercentage: min(max(readinessFromStats, 0), 100),
            familiar: familiar,
            reinforced: reinforced,
            mastered: mastered,
            expert: expert,
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

// MARK: - Readiness Calculation Helper
private extension HomeStatisticsService {
    /// Calculates readiness contribution for a single question based on correct count only.
    /// - Parameter correctCount: Number of times answered correctly
    /// - Returns: Contribution value between 0.0 and 1.0
    func readinessContribution(correctCount: Int) -> Double {
        switch correctCount {
        case 0: return 0.0
        case 1: return 0.25
        case 2: return 0.5
        case 3: return 0.75
        default: return 1.0  // 4+ correct = full credit
        }
    }
}

