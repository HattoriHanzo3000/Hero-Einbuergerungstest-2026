//
//  EagleLevelUpService.swift
//  Leben in Deutschland
//
//  Tracks last seen eagle stage and determines when to show level-up splash.
//

import Foundation

// MARK: - Eagle Level Up Service
/// Checks readiness against last-seen stage. Returns new stage only when user has leveled up (egg excluded).
enum EagleLevelUpService {
    /// Returns the new stage if user just leveled up (previous < current and current != egg). Nil otherwise.
    static func checkForLevelUp(newReadinessPercentage: Int) -> EagleStage? {
        let current = EagleStage.stage(for: newReadinessPercentage)
        guard current != .egg else { return nil }
        let lastSeen = lastSeenStage
        guard current > lastSeen else { return nil }
        return current
    }

    /// Call after user dismisses the level-up splash.
    static func markStageSeen(_ stage: EagleStage) {
        UserDefaults.standard.set(stage.rawValue, forKey: UserDefaultsKeys.eagleLastSeenStage)
    }

    private static var lastSeenStage: EagleStage {
        let raw = UserDefaults.standard.integer(forKey: UserDefaultsKeys.eagleLastSeenStage)
        return EagleStage(rawValue: raw) ?? .egg
    }
}
