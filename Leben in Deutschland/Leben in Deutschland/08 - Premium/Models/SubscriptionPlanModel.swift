//
//  SubscriptionPlanModel.swift
//  Leben in Deutschland
//
//  Model for subscription plans
//

import Foundation

enum SubscriptionPlanType {
    case monthly
    case lifetime
}

struct SubscriptionPlanModel {
    let type: SubscriptionPlanType
    let price: String
    let periodKey: String?
    let originalPrice: String?
    let isLimitedOffer: Bool
    
    static let monthlyPlan = SubscriptionPlanModel(
        type: .monthly,
        price: "2,99",
        periodKey: "premium_per_month",
        originalPrice: nil,
        isLimitedOffer: false
    )
    
    static let lifetimePlan = SubscriptionPlanModel(
        type: .lifetime,
        price: "9,99",
        periodKey: nil,
        originalPrice: "11,99",
        isLimitedOffer: true
    )
}

