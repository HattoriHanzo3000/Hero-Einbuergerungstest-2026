//
//  RevenueCatPurchaseController.swift
//  Leben in Deutschland
//
//  Superwall PurchaseController that delegates all purchases and restores to RevenueCat.
//  Keeps Superwall's subscriptionStatus in sync with RevenueCat entitlements.
//

import Foundation
import RevenueCat
import SuperwallKit
import StoreKit

// MARK: - Errors
private enum PurchasingError: LocalizedError {
    case sk2ProductNotFound

    var errorDescription: String? {
        switch self {
        case .sk2ProductNotFound:
            return "Superwall didn't pass a StoreKit 2 product. Ensure Superwall is configured for StoreKit 2."
        }
    }
}

// MARK: - RevenueCat Purchase Controller
/// Bridges Superwall paywall purchases to RevenueCat. Pass to Superwall.configure(purchaseController:).
final class RevenueCatPurchaseController: PurchaseController {

    // MARK: - Sync Subscription Status
    /// Keeps Superwall.subscriptionStatus in sync with RevenueCat entitlements.
    /// Call once after Superwall.configure. Runs indefinitely.
    func syncSubscriptionStatus() {
        assert(Purchases.isConfigured, "Configure RevenueCat before calling syncSubscriptionStatus.")
        Task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                let superwallEntitlements = customerInfo.entitlements.activeInCurrentEnvironment.keys.map {
                    Entitlement(id: $0)
                }
                await MainActor.run {
                    Superwall.shared.subscriptionStatus = .active(Set(superwallEntitlements))
                }
            }
        }
    }

    // MARK: - PurchaseController
    @MainActor
    func purchase(product: SuperwallKit.StoreProduct) async -> PurchaseResult {
        do {
            guard let sk2Product = product.sk2Product else {
                throw PurchasingError.sk2ProductNotFound
            }
            let storeProduct = RevenueCat.StoreProduct(sk2Product: sk2Product)
            let result = try await Purchases.shared.purchase(product: storeProduct)
            if result.userCancelled {
                return .cancelled
            }
            return .purchased
        } catch let error as ErrorCode {
            if error == .paymentPendingError {
                return .pending
            }
            return .failed(error)
        } catch {
            return .failed(error)
        }
    }

    @MainActor
    func restorePurchases() async -> RestorationResult {
        do {
            _ = try await Purchases.shared.restorePurchases()
            return .restored
        } catch {
            return .failed(error)
        }
    }
}
