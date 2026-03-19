//
//  DebugAwareHomeStatisticsProvider.swift
//  Leben in Deutschland
//
//  Wraps HomeStatisticsService and applies DebugOverrides.readinessPercentOverride when set.
//  Uses predefined presets with diverse (familiar, reinforced, mastered, expert) for varied ring display.
//  Only compiled in DEBUG builds.
//

#if DEBUG
import Foundation

/// Predefined readiness presets with diverse counts so color rings look varied and realistic.
private enum DebugReadinessPreset {
    /// (familiar, reinforced, mastered, expert) — total 310, readiness ≈ target %
    static func preset(for percent: Int) -> (familiar: Int, reinforced: Int, mastered: Int, expert: Int)? {
        switch percent {
        case 10: return (28, 4, 2, 0)   // ~10%, early learner
        case 30: return (80, 60, 30, 20)  // ~30%, building up
        case 50: return (60, 50, 50, 90)   // ~50%, halfway
        case 76: return (24, 36, 153, 97) // ~76%, non-round buckets for ring variety
        case 80: return (30, 40, 80, 120)  // ~80%, almost ready
        case 100: return (0, 0, 0, 310)    // 100%, all expert
        default: return nil
        }
    }

    static func readinessPercentage(familiar: Int, reinforced: Int, mastered: Int, expert: Int, total: Int) -> Int {
        let contrib = Double(familiar) * 0.25 + Double(reinforced) * 0.5 + Double(mastered) * 0.75 + Double(expert) * 1.0
        return min(max(Int((contrib / Double(total)) * 100), 0), 100)
    }
}

/// HomeStatisticsProviding that returns mock readiness when DebugOverrides.readinessPercentOverride > 0.
final class DebugAwareHomeStatisticsProvider: HomeStatisticsProviding {
    private let wrapped: HomeStatisticsProviding

    init(wrapping wrapped: HomeStatisticsProviding = HomeStatisticsService()) {
        self.wrapped = wrapped
    }

    func loadStatistics(selectedState: String?) -> HomeStatisticsModel {
        let override = DebugOverrides.shared.readinessPercentOverride
        guard let preset = DebugReadinessPreset.preset(for: override) else {
            return wrapped.loadStatistics(selectedState: selectedState)
        }
        let total = LayoutMetrics.totalFederalQuestions
        let readiness = DebugReadinessPreset.readinessPercentage(
            familiar: preset.familiar,
            reinforced: preset.reinforced,
            mastered: preset.mastered,
            expert: preset.expert,
            total: total
        )
        return HomeStatisticsModel(
            readinessPercentage: readiness,
            familiar: preset.familiar,
            reinforced: preset.reinforced,
            mastered: preset.mastered,
            expert: preset.expert,
            totalQuestions: total
        )
    }
}
#endif
