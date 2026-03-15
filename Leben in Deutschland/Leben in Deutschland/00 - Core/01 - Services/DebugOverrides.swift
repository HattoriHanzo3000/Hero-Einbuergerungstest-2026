//
//  DebugOverrides.swift
//  Leben in Deutschland
//
//  Debug-only overrides for premium status and readiness. Used by Developer Menu.
//  Only compiled in DEBUG builds.
//

#if DEBUG
import Foundation
import Combine

/// Debug-only overrides for testing different app states. Access via DebugOverrides.shared.
@MainActor
final class DebugOverrides: ObservableObject {
    static let shared = DebugOverrides()

    private let defaults = UserDefaults.standard

    /// When non-nil, overrides premium status. nil = use real RevenueCat value.
    @Published var simulatePremium: Bool? {
        didSet {
            if let v = simulatePremium {
                defaults.set(v, forKey: UserDefaultsKeys.debugSimulatePremium)
            } else {
                defaults.removeObject(forKey: UserDefaultsKeys.debugSimulatePremium)
            }
        }
    }

    /// When non-zero, overrides readiness percentage. 0 = use real statistics.
    @Published var readinessPercentOverride: Int {
        didSet {
            defaults.set(readinessPercentOverride, forKey: UserDefaultsKeys.debugReadinessPercent)
        }
    }

    var isSimulatePremiumSet: Bool { simulatePremium != nil }
    var isReadinessOverrideActive: Bool { readinessPercentOverride > 0 }

    private init() {
        if defaults.object(forKey: UserDefaultsKeys.debugSimulatePremium) != nil {
            self.simulatePremium = defaults.bool(forKey: UserDefaultsKeys.debugSimulatePremium)
        } else {
            self.simulatePremium = nil
        }
        self.readinessPercentOverride = defaults.integer(forKey: UserDefaultsKeys.debugReadinessPercent)
        if readinessPercentOverride < 0 || readinessPercentOverride > 100 {
            readinessPercentOverride = 0
        }
    }

    func clearAll() {
        simulatePremium = nil
        readinessPercentOverride = 0
    }
}
#endif
