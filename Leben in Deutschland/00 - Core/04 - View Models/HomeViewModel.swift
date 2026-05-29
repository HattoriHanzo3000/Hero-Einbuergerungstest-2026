import Foundation
import Combine

// MARK: - Home View Model
/// Binds the home screen to the learner's spaced-repetition statistics.
@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var statistics: HomeStatisticsModel

    private let statisticsProvider: HomeStatisticsProviding
    private let stateManager: StateManager
    private var cancellables = Set<AnyCancellable>()

    /// Call from MainActor (e.g. `MainActor.assumeIsolated` or `@MainActor` context). Dependencies are required to avoid main-actor-isolated defaults in Swift 6.
    init(statisticsProvider: HomeStatisticsProviding, stateManager: StateManager) {
        self.statisticsProvider = statisticsProvider
        self.stateManager = stateManager
        self.statistics = statisticsProvider.loadStatistics(selectedState: stateManager.selectedState)

        stateManager.$selectedState
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshStatistics()
            }
            .store(in: &cancellables)
    }

    /// Refreshes the cached statistics (triggered when the view appears or when selected state changes).
    func refreshStatistics() {
        statistics = statisticsProvider.loadStatistics(selectedState: stateManager.selectedState)
    }
}

