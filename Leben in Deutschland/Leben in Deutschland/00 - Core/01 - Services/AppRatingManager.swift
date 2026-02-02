import Foundation
import StoreKit
import SwiftUI
import UIKit
import Combine

// MARK: - App Rating Managing
/// Protocol for managing app rating prompts
protocol AppRatingManaging: AnyObject {
    func shouldPromptForRating() -> Bool
    func recordAppLaunch()
    func requestReview()
    func userChoseLater()
    func userChoseToRate()
}

// MARK: - App Rating Manager
/// Manages when and how to prompt users for app ratings and reviews.
/// Follows Apple's guidelines: prompts after meaningful engagement (7+ days, 10+ launches).
final class AppRatingManager: ObservableObject, AppRatingManaging {
    static let shared = AppRatingManager()
    
    @Published var showingRatingPrompt = false
    
    private let defaults: UserDefaults
    private let firstLaunchKey = "AppRating_FirstLaunchDate"
    private let launchCountKey = "AppRating_LaunchCount"
    private let lastPromptDateKey = "AppRating_LastPromptDate"
    private let userDeclinedKey = "AppRating_UserDeclined"
    private let userRatedKey = "AppRating_UserRated"
    
    // Thresholds for showing rating prompt
    private let minimumDaysSinceFirstLaunch = 7
    private let minimumLaunchCount = 10
    private let daysBetweenPrompts = 90 // Don't prompt more than once every 90 days
    
    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    // MARK: - Public Methods
    
    /// Records an app launch and checks if we should prompt for rating
    func recordAppLaunch() {
        let now = Date()
        
        // Record first launch date if not set
        if defaults.object(forKey: firstLaunchKey) == nil {
            defaults.set(now, forKey: firstLaunchKey)
            defaults.set(1, forKey: launchCountKey)
            return
        }
        
        // Increment launch count
        let currentCount = defaults.integer(forKey: launchCountKey)
        defaults.set(currentCount + 1, forKey: launchCountKey)
        
        // Check if we should prompt (but don't show automatically - let the view decide when)
    }
    
    /// Determines if we should prompt the user for a rating
    func shouldPromptForRating() -> Bool {
        // Don't prompt if user already rated
        if defaults.bool(forKey: userRatedKey) {
            return false
        }
        
        // Don't prompt if user declined recently (within 90 days)
        if let lastDeclinedDate = defaults.object(forKey: lastPromptDateKey) as? Date {
            let daysSinceLastPrompt = Calendar.current.dateComponents([.day], from: lastDeclinedDate, to: Date()).day ?? 0
            if daysSinceLastPrompt < daysBetweenPrompts {
                return false
            }
        }
        
        // Check if user has been using the app for at least minimumDaysSinceFirstLaunch
        guard let firstLaunchDate = defaults.object(forKey: firstLaunchKey) as? Date else {
            return false
        }
        
        let daysSinceFirstLaunch = Calendar.current.dateComponents([.day], from: firstLaunchDate, to: Date()).day ?? 0
        if daysSinceFirstLaunch < minimumDaysSinceFirstLaunch {
            return false
        }
        
        // Check if user has launched the app at least minimumLaunchCount times
        let launchCount = defaults.integer(forKey: launchCountKey)
        if launchCount < minimumLaunchCount {
            return false
        }
        
        return true
    }
    
    /// Requests a review using StoreKit (native iOS rating prompt)
    func requestReview() {
        // Use StoreKit's native review request (iOS 18+ API)
        // Note: iOS may not show the prompt if user was recently prompted
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            AppStore.requestReview(in: windowScene)
        }
    }
    
    /// Called when user chooses "Do it now" - shows native rating prompt
    func userChoseToRate() {
        defaults.set(true, forKey: userRatedKey)
        defaults.set(Date(), forKey: lastPromptDateKey)
        showingRatingPrompt = false
        requestReview()
    }
    
    /// Called when user chooses "Ask later" - delays next prompt
    func userChoseLater() {
        defaults.set(Date(), forKey: lastPromptDateKey)
        showingRatingPrompt = false
    }
}

