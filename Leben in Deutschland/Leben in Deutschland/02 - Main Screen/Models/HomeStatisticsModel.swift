import Foundation

// MARK: - Home Statistics Model
/// Snapshot of the learner’s spaced-repetition performance used on the home screen.
struct HomeStatisticsModel: Equatable {
    let readinessPercentage: Int
    let wrong: Int
    let familiar: Int
    let reinforced: Int
    let mastered: Int
    let totalQuestions: Int
    
    /// Fallback instance used when no statistics are stored yet.
    static let placeholder = HomeStatisticsModel(
        readinessPercentage: 0,
        wrong: 0,
        familiar: 0,
        reinforced: 0,
        mastered: 0,
        totalQuestions: LayoutMetrics.totalFederalQuestions
    )
    
    /// Indicates whether we have any recorded repetitions.
    var hasRecordedProgress: Bool {
        wrong + familiar + reinforced + mastered > 0
    }
    
    /// Total number of answered questions tracked by spaced repetition.
    var totalTrackedQuestions: Int {
        wrong + familiar + reinforced + mastered
    }
}

