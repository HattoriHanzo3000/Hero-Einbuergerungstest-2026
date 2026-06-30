import Foundation
import StoreKit
import UIKit

// MARK: - App Rating Managing
protocol AppRatingManaging: AnyObject {
    func recordAppLaunch()
    func isEligibleForReviewRequest() -> Bool
    func requestReviewIfEligible()
    func openAppStoreReviewPage()
}

// MARK: - App Rating Manager
/// Manages when and how to request App Store ratings via the system review API.
/// Prompts after meaningful engagement (3+ days or 10+ launches), throttled to once per 90 days.
@MainActor
final class AppRatingManager: AppRatingManaging {
    static let shared = AppRatingManager()

    private let defaults: UserDefaults
    private let firstLaunchKey = "AppRating_FirstLaunchDate"
    private let launchCountKey = "AppRating_LaunchCount"
    private let lastPromptDateKey = "AppRating_LastPromptDate"

    private let minimumDaysSinceFirstLaunch = 3
    private let minimumLaunchCount = 10
    private let daysBetweenPrompts = 90

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Public Methods

    func recordAppLaunch() {
        let now = Date()

        if defaults.object(forKey: firstLaunchKey) == nil {
            defaults.set(now, forKey: firstLaunchKey)
            defaults.set(1, forKey: launchCountKey)
            return
        }

        let currentCount = defaults.integer(forKey: launchCountKey)
        defaults.set(currentCount + 1, forKey: launchCountKey)
    }

    func isEligibleForReviewRequest() -> Bool {
        if let lastRequestDate = defaults.object(forKey: lastPromptDateKey) as? Date {
            let daysSinceLastRequest = Calendar.current.dateComponents(
                [.day],
                from: lastRequestDate,
                to: Date()
            ).day ?? 0
            if daysSinceLastRequest < daysBetweenPrompts {
                return false
            }
        }

        guard let firstLaunchDate = defaults.object(forKey: firstLaunchKey) as? Date else {
            return false
        }

        let daysSinceFirstLaunch = Calendar.current.dateComponents(
            [.day],
            from: firstLaunchDate,
            to: Date()
        ).day ?? 0
        let launchCount = defaults.integer(forKey: launchCountKey)

        return daysSinceFirstLaunch >= minimumDaysSinceFirstLaunch || launchCount >= minimumLaunchCount
    }

    func requestReviewIfEligible() {
        guard isEligibleForReviewRequest(), requestReview() else { return }
        defaults.set(Date(), forKey: lastPromptDateKey)
    }

    /// Opens the App Store write-review page (for explicit user action in Settings).
    func openAppStoreReviewPage() {
        UIApplication.shared.open(AppURLs.appStoreWriteReviewURL)
    }

    // MARK: - Private Methods

    @discardableResult
    private func requestReview() -> Bool {
        guard let windowScene = activeWindowScene else { return false }
        AppStore.requestReview(in: windowScene)
        return true
    }

    private var activeWindowScene: UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first
    }
}
