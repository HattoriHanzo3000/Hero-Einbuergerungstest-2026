import Foundation

// MARK: - Home Statistics Model
/// Snapshot of the learner’s spaced-repetition performance used on the home screen.
struct HomeStatisticsModel: Equatable {
    let readinessPercentage: Int
    let familiar: Int      // 1 correct
    let reinforced: Int     // 2 correct
    let mastered: Int      // 3 correct
    let expert: Int        // 4+ correct
    let totalQuestions: Int
    
    /// Fallback instance used when no statistics are stored yet.
    static let placeholder = HomeStatisticsModel(
        readinessPercentage: 0,
        familiar: 0,
        reinforced: 0,
        mastered: 0,
        expert: 0,
        totalQuestions: LayoutMetrics.totalFederalQuestions
    )
    
    /// Indicates whether we have any recorded repetitions.
    var hasRecordedProgress: Bool {
        familiar + reinforced + mastered + expert > 0
    }
    
    /// Total number of answered questions tracked by spaced repetition.
    var totalTrackedQuestions: Int {
        familiar + reinforced + mastered + expert
    }
}

