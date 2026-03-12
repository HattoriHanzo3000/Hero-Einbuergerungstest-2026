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
        let presentationHandler = PaywallPresentationHandler()
        presentationHandler.onDismiss { [weak self] _, _ in
            Task { @MainActor in
                await self?.refreshPremiumStatus()
            }
        }
        Superwall.shared.register(placement: placement, handler: presentationHandler)
    }

    /// Triggers Superwall placement for a gated feature. Handler runs only when user has access (purchased, restored, or already subscribed).
    func gateFeature(placement: String, handler: @escaping () -> Void) {
        if isPremium {
            handler()
            return
        }
        let presentationHandler = PaywallPresentationHandler()
        presentationHandler.onDismiss { [weak self] _, result in
            Task { @MainActor in
                await self?.refreshPremiumStatus()
                switch result {
                case .purchased, .restored:
                    handler()
                case .declined:
                    break
                @unknown default:
                    break
                }
            }
        }
        Superwall.shared.register(placement: placement, handler: presentationHandler)
    }
}
