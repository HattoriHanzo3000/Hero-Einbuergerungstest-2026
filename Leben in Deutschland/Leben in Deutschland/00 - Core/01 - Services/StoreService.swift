//
//  StoreService.swift
//  Leben in Deutschland
//
//  StoreKit 2 service for subscription purchases and restore.
//  Product IDs must match App Store Connect: hero_premium_monthly, hero_premium_yearly.
//

import Foundation
import StoreKit
import Combine

/// StoreKit 2 service for loading products, purchasing, and restoring subscriptions.
@MainActor
final class StoreService: ObservableObject {
    static let shared = StoreService()
    
    /// Product IDs — must match App Store Connect subscription product IDs.
    private enum ProductID {
        static let monthly = "hero_premium_monthly"
        static let yearly = "hero_premium_yearly"
        static var all: [String] { [monthly, yearly] }
    }
    
    @Published private(set) var monthlyProduct: Product?
    @Published private(set) var yearlyProduct: Product?
    @Published private(set) var isLoading = false
    @Published private(set) var purchaseError: String?
    
    private init() {}
    
    // MARK: - Load Products
    
    /// Loads subscription products from the App Store.
    func loadProducts() async {
        isLoading = true
        purchaseError = nil
        defer { isLoading = false }
        
        do {
            let products = try await Product.products(for: ProductID.all)
            monthlyProduct = products.first { $0.id == ProductID.monthly }
            yearlyProduct = products.first { $0.id == ProductID.yearly }
        } catch {
            purchaseError = error.localizedDescription
        }
    }
    
    // MARK: - Purchase
    
    /// Purchases the selected subscription. Returns true on success.
    func purchase(_ plan: SubscriptionPlanType) async -> Bool {
        purchaseError = nil
        let product: Product?
        switch plan {
        case .monthly: product = monthlyProduct
        case .yearly: product = yearlyProduct
        case .lifetime: product = nil
        }
        
        guard let product else {
            purchaseError = "Product not available"
            return false
        }
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await syncEntitlement(transaction: transaction)
                await transaction.finish()
                return true
            case .userCancelled:
                return false
            case .pending:
                purchaseError = "Purchase is pending approval"
                return false
            @unknown default:
                purchaseError = "Unknown purchase result"
                return false
            }
        } catch {
            purchaseError = error.localizedDescription
            return false
        }
    }
    
    /// Syncs current entitlements with PremiumManager (e.g. on app launch).
    /// Call this at startup to detect subscriptions from previous installs or renewals.
    func syncEntitlementsOnLaunch() async {
        _ = await restorePurchases()
    }
    
    // MARK: - Restore
    
    /// Restores purchases by syncing current entitlements with PremiumManager.
    /// Returns true if an active subscription was found.
    func restorePurchases() async -> Bool {
        purchaseError = nil
        var foundActive = false
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.revocationDate == nil {
                await syncEntitlement(transaction: transaction)
                foundActive = true
            }
        }
        
        return foundActive
    }
    
    // MARK: - Helpers
    
    private func syncEntitlement(transaction: Transaction) async {
        let planType = planType(for: transaction.productID)
        let expiry = transaction.expirationDate
        await MainActor.run {
            PremiumManager.shared.activateSubscription(type: planType, expiryDate: expiry)
        }
    }
    
    private func planType(for productID: String) -> SubscriptionPlanType {
        if productID.contains("yearly") { return .yearly }
        if productID.contains("monthly") { return .monthly }
        return .yearly
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value): return value
        case .unverified: throw StoreError.verificationFailed
        }
    }
}

private enum StoreError: Error {
    case verificationFailed
}
