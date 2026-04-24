//
//  SubscriptionPlanModel.swift
//  Leben in Deutschland
//
//  Model for subscription plans
//

import Foundation

enum SubscriptionPlanType {
    case monthly
    case yearly
    case lifetime
}

struct SubscriptionPlanModel {
    let type: SubscriptionPlanType
    let price: String
    let periodKey: String?
    let originalPrice: String?
    let isLimitedOffer: Bool
    /// Optional subtitle key (e.g. savings hint for yearly).
    let subtitleKey: String?
    
    static let monthlyPlan = SubscriptionPlanModel(
        type: .monthly,
        price: "1,99",
        periodKey: "pro_per_month",
        originalPrice: nil,
        isLimitedOffer: false,
        subtitleKey: nil
    )
    
    static let yearlyPlan = SubscriptionPlanModel(
        type: .yearly,
        price: "14,99",
        periodKey: "pro_per_year",
        originalPrice: nil,
        isLimitedOffer: true,
        subtitleKey: "paywall_year_savings"
    )
    
    static let lifetimePlan = SubscriptionPlanModel(
        type: .lifetime,
        price: "49,99",
        periodKey: nil,
        originalPrice: "11,99",
        isLimitedOffer: true,
        subtitleKey: nil
    )
}

