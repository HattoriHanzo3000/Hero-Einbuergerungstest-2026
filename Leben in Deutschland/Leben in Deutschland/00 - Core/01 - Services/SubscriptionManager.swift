//
//  SubscriptionManager.swift
//  Leben in Deutschland
//
//  Source of truth for premium status. Uses RevenueCat entitlements only.
//  No manual trial logic — use App Store Connect / RevenueCat for trials.
//

import Foundation
import Combine
import RevenueCat
import SuperwallKit

/// Manages premium subscription status. RevenueCat is the sole source of truth.
@MainActor
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published private(set) var isPremium: Bool = false

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

    // MARK: - Superwall Placements
    /// Triggers Superwall placement. Use for crown tap or generic paywall.
    func presentPaywall(placement: String = "paywall_trigger") {
        Superwall.shared.register(placement: placement) {
            Task { @MainActor in
                await self.refreshPremiumStatus()
            }
        }
    }

    /// Triggers Superwall placement for a gated feature. Handler runs if user has access.
    func gateFeature(placement: String, handler: @escaping () -> Void) {
        Superwall.shared.register(placement: placement) {
            Task { @MainActor in
                await self.refreshPremiumStatus()
            }
            handler()
        }
    }
}
