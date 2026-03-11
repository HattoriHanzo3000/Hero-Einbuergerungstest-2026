//
//  Configuration.swift
//  Leben in Deutschland
//
//  Central configuration for API keys and feature flags.
//  Replace placeholders with production keys before release.
//

import Foundation

enum AppConfiguration {
    // MARK: - RevenueCat
    /// RevenueCat Public API Key. Set in App Store Connect / RevenueCat dashboard.
    static let revenueCatAPIKey = "YOUR_REVENUECAT_PUBLIC_API_KEY"
    
    // MARK: - Superwall
    /// Superwall Public API Key. Set in Superwall dashboard.
    static let superwallAPIKey = "YOUR_SUPERWALL_PUBLIC_API_KEY"
    
    // MARK: - Entitlement
    /// RevenueCat entitlement identifier for premium access.
    static let premiumEntitlementId = "premium"
}
