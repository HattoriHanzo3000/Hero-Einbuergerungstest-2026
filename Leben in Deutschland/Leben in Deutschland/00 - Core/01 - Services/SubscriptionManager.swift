//
//  SubscriptionManager.swift
//  Leben in Deutschland
//
//  Source of truth for premium status. Uses RevenueCat entitlements only.
//  Presents SwiftUI PaywallView (RevenueCat) instead of Superwall.
//

import Foundation
import Combine
import RevenueCat
import SwiftUI

/// Content for the feature preview disclaimer shown to free users before the paywall.
struct FeaturePreviewContent {
    let titleKey: String
    let messageKey: String
    let accentColorName: String
}

/// Manages premium subscription status. RevenueCat is the sole source of truth.
@MainActor
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published private(set) var isPremium: Bool = false
    /// When true, present PaywallView as a sheet. Set by presentPaywall().
    @Published var showPaywall: Bool = false

    /// When true, present FeaturePreviewDisclaimerSheet. Free users see this before the paywall.
    @Published var showFeaturePreviewSheet: Bool = false
    @Published var featurePreviewContent: FeaturePreviewContent?

    private let entitlementId = AppConfiguration.premiumEntitlementId
    private var customerInfoTask: Task<Void, Never>?

    private init() {
        startObservingCustomerInfo()
    }

    deinit {
        customerInfoTask?.cancel()
    }

    // MARK: - RevenueCat Observation
    private func startObservingCustomerInfo() {
        guard Purchases.isConfigured else { return }
        customerInfoTask?.cancel()
        customerInfoTask = Task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                guard !Task.isCancelled else { return }
                let active = customerInfo.entitlements.all[entitlementId]?.isActive == true
                await MainActor.run {
                    self.isPremium = active
                }
            }
        }
    }

    /// Refreshes premium status from RevenueCat. Call on app launch.
    func refreshPremiumStatus() async {
        guard Purchases.isConfigured else { return }
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            isPremium = customerInfo.entitlements.all[entitlementId]?.isActive == true
        } catch {
            print("SubscriptionManager: Failed to refresh — \(error)")
        }
    }

    // MARK: - Paywall Presentation
    /// Presents the SwiftUI PaywallView (RevenueCat). Callers should observe showPaywall and present a sheet.
    func presentPaywall(placement: String = "paywall_trigger") {
        showPaywall = true
    }

    /// Dismisses the paywall sheet. Call when user closes PaywallView.
    func dismissPaywall() {
        showPaywall = false
    }

    /// For gated features: if premium, runs handler; otherwise presents paywall.
    func gateFeature(placement: String, handler: @escaping () -> Void) {
        if isPremium {
            handler()
            return
        }
        presentPaywall(placement: placement)
    }

    /// For premium-gated features: if premium, runs handler; otherwise shows feature preview disclaimer first, then paywall on dismiss.
    /// Use for Learn by Topics, Smart Learning, Favorites, Test Simulation so free users understand what they're unlocking.
    func gateFeatureWithPreview(
        placement: String,
        titleKey: String,
        messageKey: String,
        accentColorName: String,
        handler: @escaping () -> Void
    ) {
        if isPremium {
            handler()
            return
        }
        featurePreviewContent = FeaturePreviewContent(
            titleKey: titleKey,
            messageKey: messageKey,
            accentColorName: accentColorName
        )
        showFeaturePreviewSheet = true
    }

    /// Dismisses the feature preview sheet and presents the paywall. Call from sheet's onDismiss.
    func dismissFeaturePreviewAndPresentPaywall() {
        showFeaturePreviewSheet = false
        featurePreviewContent = nil
        presentPaywall()
    }

    /// Dismisses the feature preview sheet without showing paywall (e.g. if user became premium).
    func dismissFeaturePreviewSheet() {
        showFeaturePreviewSheet = false
        featurePreviewContent = nil
    }
}
