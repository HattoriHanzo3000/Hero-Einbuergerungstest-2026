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
    /// RevenueCat Public API Key (Test Store for development).
    static let revenueCatAPIKey = "test_MAziVxFjwMzqPkdjDmnoGubtHVj"
    
    // MARK: - Superwall
    /// Superwall Public API Key. Set in Superwall dashboard.
    static let superwallAPIKey = "pk_ggK4lMHzvT_dnwyVPF1FX"
    
    // MARK: - Entitlement
    /// RevenueCat entitlement identifier for premium access.
    static let premiumEntitlementId = "premium"
}
