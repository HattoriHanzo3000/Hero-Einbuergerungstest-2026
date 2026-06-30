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

        let manager = SpacedRepetitionManager.shared
        let totalQuestions = LayoutMetrics.totalFederalQuestions
        let buckets = manager.progressBuckets(totalQuestions: totalQuestions)

        return HomeStatisticsModel(
            readinessPercentage: manager.readinessPercentage(totalQuestions: totalQuestions),
            familiar: buckets.familiar,
            reinforced: buckets.reinforced,
            mastered: buckets.mastered,
            expert: buckets.expert,
            totalQuestions: totalQuestions
        )
    }
}
