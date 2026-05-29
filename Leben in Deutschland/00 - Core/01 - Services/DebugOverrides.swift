//
//  DebugOverrides.swift
//  Leben in Deutschland
//
//  Debug-only overrides for pro status and readiness. Used by Developer Menu.
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

    /// When non-nil, overrides pro status. nil = use real RevenueCat value.
    @Published var simulatePro: Bool? {
        didSet {
            if let v = simulatePro {
                defaults.set(v, forKey: UserDefaultsKeys.debugSimulatePro)
            } else {
                defaults.removeObject(forKey: UserDefaultsKeys.debugSimulatePro)
            }
        }
    }

    /// When non-zero, overrides readiness percentage. 0 = use real statistics.
    @Published var readinessPercentOverride: Int {
        didSet {
            defaults.set(readinessPercentOverride, forKey: UserDefaultsKeys.debugReadinessPercent)
        }
    }

    var isSimulateProSet: Bool { simulatePro != nil }
    var isReadinessOverrideActive: Bool { readinessPercentOverride > 0 }

    private init() {
        if defaults.object(forKey: UserDefaultsKeys.debugSimulatePro) != nil {
            self.simulatePro = defaults.bool(forKey: UserDefaultsKeys.debugSimulatePro)
        } else {
            self.simulatePro = nil
        }
        self.readinessPercentOverride = defaults.integer(forKey: UserDefaultsKeys.debugReadinessPercent)
        if readinessPercentOverride < 0 || readinessPercentOverride > 100 {
            readinessPercentOverride = 0
        }
    }

    func clearAll() {
        simulatePro = nil
        readinessPercentOverride = 0
    }
}
#endif
