//
//  PremiumManager.swift
//  Leben in Deutschland
//
//  Manages premium subscription status and free trial period
//

import Foundation
import Combine

/// Manages premium subscription status, including free trial period
@MainActor
final class PremiumManager: ObservableObject {
    static let shared = PremiumManager()
    
    private let defaults: UserDefaults
    
    @Published var isPremium: Bool = false
    @Published var isTrialActive: Bool = false
    @Published var trialDaysRemaining: Int = 0
    
    private enum Keys {
        static let trialStartDate = "premium_trial_start_date"
        static let trialUsed = "premium_trial_used"
        static let subscriptionType = "premium_subscription_type" // "monthly", "lifetime", nil
        static let subscriptionExpiryDate = "premium_subscription_expiry_date"
    }
    
    private let trialDurationDays: Int = 3
    
    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        checkPremiumStatus()
    }
    
    // MARK: - Public Methods
    
    /// Starts the free trial period (should be called once when user first opens premium features)
    func startFreeTrial() {
        // Only start trial if it hasn't been used before
        guard !hasUsedTrial else {
            return
        }
        
        let startDate = Date()
        defaults.set(startDate.timeIntervalSince1970, forKey: Keys.trialStartDate)
        defaults.set(true, forKey: Keys.trialUsed)
        
        checkPremiumStatus()
    }
    
    /// Checks if user has active premium access (trial or paid subscription)
    func checkPremiumStatus() {
        // Check if user has active paid subscription
        if let subscriptionType = defaults.string(forKey: Keys.subscriptionType) {
            if subscriptionType == "lifetime" {
                // Lifetime subscription never expires
                isPremium = true
                isTrialActive = false
                trialDaysRemaining = 0
                return
            } else if subscriptionType == "monthly" {
                // Check if monthly subscription is still valid
                if let expiryDate = getSubscriptionExpiryDate(),
                   expiryDate > Date() {
                    isPremium = true
                    isTrialActive = false
                    trialDaysRemaining = 0
                    return
                } else {
                    // Subscription expired, clear it
                    clearSubscription()
                }
            }
        }
        
        // Check if trial is active
        if let trialStartDate = getTrialStartDate() {
            let trialEndDate = Calendar.current.date(byAdding: .day, value: trialDurationDays, to: trialStartDate) ?? trialStartDate
            
            if trialEndDate > Date() {
                // Trial is still active
                isPremium = true
                isTrialActive = true
                let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: trialEndDate).day ?? 0
                trialDaysRemaining = max(0, daysRemaining)
                return
            } else {
                // Trial has expired
                isPremium = false
                isTrialActive = false
                trialDaysRemaining = 0
                return
            }
        }
        
        // No premium access
        isPremium = false
        isTrialActive = false
        trialDaysRemaining = 0
    }
    
    /// Activates premium subscription (called after successful purchase)
    func activateSubscription(type: SubscriptionPlanType, expiryDate: Date? = nil) {
        let typeString = type == .monthly ? "monthly" : "lifetime"
        defaults.set(typeString, forKey: Keys.subscriptionType)
        
        if let expiryDate = expiryDate {
            defaults.set(expiryDate.timeIntervalSince1970, forKey: Keys.subscriptionExpiryDate)
        } else if type == .lifetime {
            // Lifetime never expires, but we can set a far future date for consistency
            let farFuture = Calendar.current.date(byAdding: .year, value: 100, to: Date()) ?? Date()
            defaults.set(farFuture.timeIntervalSince1970, forKey: Keys.subscriptionExpiryDate)
        }
        
        checkPremiumStatus()
    }
    
    /// Clears subscription (for testing or logout)
    func clearSubscription() {
        defaults.removeObject(forKey: Keys.subscriptionType)
        defaults.removeObject(forKey: Keys.subscriptionExpiryDate)
        checkPremiumStatus()
    }
    
    /// Resets trial (for testing purposes only)
    func resetTrial() {
        defaults.removeObject(forKey: Keys.trialStartDate)
        defaults.removeObject(forKey: Keys.trialUsed)
        checkPremiumStatus()
    }
    
    // MARK: - Computed Properties
    
    /// Returns true if user has already used their free trial
    var hasUsedTrial: Bool {
        defaults.bool(forKey: Keys.trialUsed)
    }
    
    /// Returns true if trial is available (not used yet)
    var isTrialAvailable: Bool {
        !hasUsedTrial
    }
    
    /// Returns the trial start date if trial was started
    private func getTrialStartDate() -> Date? {
        let timeInterval = defaults.double(forKey: Keys.trialStartDate)
        return timeInterval == 0 ? nil : Date(timeIntervalSince1970: timeInterval)
    }
    
    /// Returns subscription expiry date
    private func getSubscriptionExpiryDate() -> Date? {
        let timeInterval = defaults.double(forKey: Keys.subscriptionExpiryDate)
        return timeInterval == 0 ? nil : Date(timeIntervalSince1970: timeInterval)
    }
    
    /// Returns trial end date if trial is active
    var trialEndDate: Date? {
        guard let trialStartDate = getTrialStartDate() else { return nil }
        return Calendar.current.date(byAdding: .day, value: trialDurationDays, to: trialStartDate)
    }
}

