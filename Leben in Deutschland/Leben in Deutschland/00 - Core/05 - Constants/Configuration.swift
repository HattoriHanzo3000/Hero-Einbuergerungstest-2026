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
    private static let revenueCatInfoPlistKey = "RevenueCatAPIKey"
    private static let revenueCatEnvironmentKey = "REVENUECAT_API_KEY"

    /// RevenueCat Public API Key, resolved from Info.plist first and then the environment.
    static var revenueCatAPIKey: String {
        if let key = Bundle.main.object(forInfoDictionaryKey: revenueCatInfoPlistKey) as? String {
            let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty, !trimmed.contains("$("), !trimmed.hasPrefix("YOUR_") {
                return trimmed
            }
        }

        if let key = ProcessInfo.processInfo.environment[revenueCatEnvironmentKey] {
            let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty, !trimmed.hasPrefix("YOUR_") {
                return trimmed
            }
        }

        return ""
    }
    
    // MARK: - Entitlement
    /// RevenueCat entitlement identifier for pro access.
    static let proEntitlementId = "pro"
}
