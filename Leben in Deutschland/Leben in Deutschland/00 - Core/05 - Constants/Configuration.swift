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
    /// RevenueCat Public API Key (App Store production).
    static let revenueCatAPIKey = "appl_ADBrnUbVqssHHmMCiWzsLuZYwHi"
    
    // MARK: - Entitlement
    /// RevenueCat entitlement identifier for pro access.
    static let proEntitlementId = "pro"
}
