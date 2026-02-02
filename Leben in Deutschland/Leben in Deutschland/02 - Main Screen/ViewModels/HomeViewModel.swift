import Foundation
import Combine

// MARK: - Home View Model
/// Binds the home screen to the learner’s spaced-repetition statistics.
final class HomeViewModel: ObservableObject {
    @Published private(set) var statistics: HomeStatisticsModel
    
    private let statisticsProvider: HomeStatisticsProviding
    
    init(statisticsProvider: HomeStatisticsProviding = HomeStatisticsService()) {
        self.statisticsProvider = statisticsProvider
        self.statistics = statisticsProvider.loadStatistics()
    }
    
    /// Refreshes the cached statistics (triggered when the view appears).
    func refreshStatistics() {
        statistics = statisticsProvider.loadStatistics()
    }
}

