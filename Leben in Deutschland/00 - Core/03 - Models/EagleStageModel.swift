//
//  EagleStageModel.swift
//  Leben in Deutschland
//
//  Eagle readiness stages. Used for level-up splash and header messages.
//

import Foundation

// MARK: - Eagle Stage
/// Six eagle stages mapped from readiness percentage. Egg (0%) is never shown as level-up.
enum EagleStage: Int, CaseIterable, Comparable, Identifiable {
    case egg = 0
    case chick = 1
    case young = 2
    case growing = 3
    case wise = 4
    case master = 5

    /// Localization key for eagle_desc_* messages.
    var descriptionKey: String {
        switch self {
        case .egg: return "eagle_desc_egg"
        case .chick: return "eagle_desc_chick"
        case .young: return "eagle_desc_young"
        case .growing: return "eagle_desc_growing"
        case .wise: return "eagle_desc_wise"
        case .master: return "eagle_desc_master"
        }
    }

    /// Stage from readiness percentage. Matches ReadinessMessageHelper ranges.
    static func stage(for readinessPercentage: Int) -> EagleStage {
        switch readinessPercentage {
        case 0..<5: return .egg
        case 5..<17: return .chick
        case 17..<34: return .young
        case 34..<51: return .growing
        case 51..<84: return .wise
        default: return .master
        }
    }

    static func < (lhs: EagleStage, rhs: EagleStage) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var id: Int { rawValue }
}
