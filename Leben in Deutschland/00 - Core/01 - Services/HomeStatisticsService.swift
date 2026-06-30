import Foundation

// MARK: - Home Statistics Providing
/// Abstraction that surfaces the learner’s spaced-repetition progress for the home screen.
protocol HomeStatisticsProviding {
    /// Loads statistics. Readiness is always calculated out of 310 (300 federal + 10 state-specific).
    func loadStatistics(selectedState: String?) -> HomeStatisticsModel
}

// MARK: - Home Statistics Service
/// Derives home-screen stats from spaced-repetition state for the requested federal state.
final class HomeStatisticsService: HomeStatisticsProviding {
    func loadStatistics(selectedState: String?) -> HomeStatisticsModel {
        let coordinator = ProgressPersistenceCoordinator.shared
        let resolvedState = selectedState ?? coordinator.activeFederalState
        if resolvedState != coordinator.activeFederalState {
            coordinator.reloadForFederalState(resolvedState)
        }

        let totalQuestions = LayoutMetrics.totalFederalQuestions
        let statistics = SpacedRepetitionManager.shared.statistics.values

        let familiar = statistics.filter { $0.correctCount == 1 }.count
        let reinforced = statistics.filter { $0.correctCount == 2 }.count
        let mastered = statistics.filter { $0.correctCount == 3 }.count
        let expert = statistics.filter { $0.correctCount >= 4 }.count

        let totalContribution = statistics.reduce(0.0) { sum, stats in
            sum + readinessContribution(correctCount: stats.correctCount)
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

// MARK: - Readiness Calculation Helper
private extension HomeStatisticsService {
    func readinessContribution(correctCount: Int) -> Double {
        switch correctCount {
        case 0: return 0.0
        case 1: return 0.25
        case 2: return 0.5
        case 3: return 0.75
        default: return 1.0
        }
    }
}
