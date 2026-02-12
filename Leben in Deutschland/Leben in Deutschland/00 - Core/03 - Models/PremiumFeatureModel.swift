//
//  PremiumFeatureModel.swift
//  Leben in Deutschland
//
//  Model for premium feature comparison
//

import Foundation

struct PremiumFeatureModel {
    let nameKey: String
    let isAvailableInFree: Bool
    let isAvailableInPremium: Bool
    
    static let features: [PremiumFeatureModel] = [
        PremiumFeatureModel(
            nameKey: "premium_feature_daily_lessons",
            isAvailableInFree: true,
            isAvailableInPremium: true
        ),
        PremiumFeatureModel(
            nameKey: "premium_feature_unlimited_learning",
            isAvailableInFree: false,
            isAvailableInPremium: true
        ),
        PremiumFeatureModel(
            nameKey: "premium_feature_no_ads",
            isAvailableInFree: false,
            isAvailableInPremium: true
        ),
        PremiumFeatureModel(
            nameKey: "premium_feature_detailed_progress",
            isAvailableInFree: false,
            isAvailableInPremium: true
        ),
        PremiumFeatureModel(
            nameKey: "premium_feature_hints",
            isAvailableInFree: false,
            isAvailableInPremium: true
        ),
        PremiumFeatureModel(
            nameKey: "premium_feature_favorites",
            isAvailableInFree: false,
            isAvailableInPremium: true
        )
    ]
}

