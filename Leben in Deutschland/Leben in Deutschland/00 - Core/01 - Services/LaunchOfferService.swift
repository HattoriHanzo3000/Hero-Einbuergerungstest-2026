//
//  LaunchOfferService.swift
//  Leben in Deutschland
//
//  Tracks first launch date and provides 3-day Launch Offer logic for the Lifetime plan.
//

import Foundation

enum LaunchOfferService {
    /// Promo package identifier in RevenueCat (Product: hero.lid.premium.lifetime.launch).
    static let promoPackageIdentifier = "$rc_lifetime_promo"
    /// Standard lifetime product ID in App Store Connect (matches StoreService.ProductId.lifetime).
    static let standardLifetimeProductId = "hero.lid.premium.lifetime"

    private static let launchWindowSeconds: TimeInterval = 72 * 60 * 60 // 3 days

    /// Date of first app launch. Nil if never recorded.
    static var firstLaunchDate: Date? {
        UserDefaults.standard.object(forKey: UserDefaultsKeys.firstLaunchDate) as? Date
    }

    /// True if current time is within 72 hours of first launch.
    static var isLaunchOfferActive: Bool {
        guard let launch = firstLaunchDate else { return false }
        return Date().timeIntervalSince(launch) < launchWindowSeconds
    }

    /// Seconds remaining until offer expires. 0 if expired.
    static var secondsRemaining: TimeInterval {
        guard let launch = firstLaunchDate else { return 0 }
        let elapsed = Date().timeIntervalSince(launch)
        let remaining = launchWindowSeconds - elapsed
        return max(0, remaining)
    }

    /// Formatted countdown string: "2d 04h 15m 10s"
    static func formattedCountdown(from remaining: TimeInterval) -> String {
        let d = Int(remaining) / 86400
        let h = (Int(remaining) % 86400) / 3600
        let m = (Int(remaining) % 3600) / 60
        let s = Int(remaining) % 60
        return String(format: "%dd %02dh %02dm %02ds", d, h, m, s)
    }
}
