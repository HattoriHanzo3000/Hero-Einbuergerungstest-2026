//
//  SubscriptionManager.swift
//  Leben in Deutschland
//
//  Source of truth for pro status. Uses RevenueCat entitlements only.
//  Presents SwiftUI PaywallView (RevenueCat offerings / StoreKit).
//

import Foundation
import Combine
import RevenueCat
import StoreKit
import SwiftUI

enum SubscriptionTariffState: Equatable {
    case free
    case trial
    case subscription
    case lifetime
}

/// Content for the feature preview disclaimer shown to free users before the paywall.
struct FeaturePreviewContent {
    let titleKey: String
    let messageKey: String
    let accentColorName: String
}

/// Manages pro subscription status. RevenueCat is the sole source of truth.
@MainActor
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @AppStorage(UserDefaultsKeys.lastKnownPremiumState) private var lastKnownPremiumState = false

    @Published private(set) var isPro: Bool = false
    @Published private(set) var hasCompletedInitialSubscriptionSync: Bool = false
    @Published private(set) var tariffState: SubscriptionTariffState = .free
    @Published private(set) var tariffRenewalDate: Date?
    @Published private(set) var activeProductIdentifier: String?
    @Published private(set) var appStorePlanDisplayName: String?
    @Published var showRestoreFeedbackAlert: Bool = false
    @Published var restoreFeedbackMessage: String?
    /// When true, present PaywallView as a sheet. Set by presentPaywall().
    @Published var showPaywall: Bool = false

    /// When true, present FeaturePreviewDisclaimerSheet. Free users see this before the paywall.
    @Published var showFeaturePreviewSheet: Bool = false
    @Published var featurePreviewContent: FeaturePreviewContent?

    /// Pro status used by UI. In DEBUG, respects DebugOverrides.simulatePro; otherwise uses cached/real RevenueCat state.
    var effectiveIsPro: Bool {
#if DEBUG
        if let override = DebugOverrides.shared.simulatePro {
            return override
        }
#endif
        return isPremiumVisualState
    }

    /// Visual premium state used by headers and badges during cold start.
    var isPremiumVisualState: Bool {
        hasCompletedInitialSubscriptionSync ? isPro : lastKnownPremiumState
    }

    /// Authorization state used for gating premium-only actions.
    var isPremiumAuthorizationGranted: Bool {
        hasCompletedInitialSubscriptionSync && isPro
    }

    var hasLifetimeSubscription: Bool {
        tariffState == .lifetime
    }

    var hasActiveSubscription: Bool {
        tariffState == .subscription || tariffState == .trial
    }

    var localizedTariffName: String {
        switch tariffState {
        case .free:
            return "hero_pro_tariff_free".localized
        case .trial:
            return "hero_pro_tariff_trial".localized
        case .subscription:
            return "hero_pro_tariff_subscription".localized
        case .lifetime:
            return "hero_pro_tariff_lifetime".localized
        }
    }

    var localizedPlanStatusLine: String {
        if let appStorePlanDisplayName, !appStorePlanDisplayName.isEmpty {
            return appStorePlanDisplayName
        }
        switch tariffState {
        case .free:
            return "hero_pro_status_free".localized
        case .trial:
            return "hero_pro_status_trial".localized
        case .subscription:
            return "hero_pro_status_subscription".localized
        case .lifetime:
            return "hero_pro_status_lifetime".localized
        }
    }

    var localizedPlanDetailBody: String {
        switch tariffState {
        case .free:
            return "hero_pro_detail_free_body".localized
        case .trial:
            return "hero_pro_detail_trial_body".localized
        case .subscription:
            return "hero_pro_detail_subscription_body".localized
        case .lifetime:
            return "hero_pro_detail_lifetime_body".localized
        }
    }

    var localizedPlanLifetimeThanks: String? {
        hasLifetimeSubscription ? "hero_pro_detail_lifetime_thanks".localized : nil
    }

    var localizedPlanDateLine: String? {
        guard let renewalDate = tariffRenewalDate else { return nil }
        let formattedDate = DateFormatter.localizedString(from: renewalDate, dateStyle: .medium, timeStyle: .none)
        switch tariffState {
        case .trial:
            return String(format: "hero_pro_trial_ends_format".localized, formattedDate)
        case .subscription:
            return String(format: "hero_pro_renews_format".localized, formattedDate)
        case .free, .lifetime:
            return nil
        }
    }

    var showsManageSubscriptionAction: Bool {
        tariffState == .subscription || tariffState == .trial
    }

    var showsViewPlansAction: Bool {
        tariffState != .lifetime
    }

    var showsRestoreAction: Bool {
        tariffState == .free
    }

    var showsRedeemAction: Bool {
        tariffState != .lifetime
    }

    private let entitlementId = AppConfiguration.premiumEntitlementId
    private var customerInfoTask: Task<Void, Never>?
    #if DEBUG
    private var debugCancellable: AnyCancellable?
    #endif

    private init() {
        applyCachedCustomerInfoIfAvailable()
        #if DEBUG
        debugCancellable = DebugOverrides.shared.$simulatePro
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
        #endif
        startObservingCustomerInfo()
        Task { await refreshProStatus() }
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
                    self.applyCustomerInfo(customerInfo, activeOverride: active)
                }
            }
        }
    }

    /// Refreshes pro status from RevenueCat. Call on app launch.
    func refreshProStatus() async {
        guard Purchases.isConfigured else {
            hasCompletedInitialSubscriptionSync = true
            return
        }
        defer { hasCompletedInitialSubscriptionSync = true }
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            applyCustomerInfo(customerInfo)
        } catch {
            print("SubscriptionManager: Failed to refresh — \(error)")
        }
    }

    func restorePurchases() async {
        do {
            _ = try await Purchases.shared.restorePurchases()
            await refreshProStatus()
            restoreFeedbackMessage = effectiveIsPro
                ? "paywall_restore_success".localized
                : "paywall_restore_no_subscription".localized
        } catch {
            restoreFeedbackMessage = error.localizedDescription
        }
        showRestoreFeedbackAlert = true
    }

    func dismissRestoreFeedbackAlert() {
        showRestoreFeedbackAlert = false
        restoreFeedbackMessage = nil
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

    /// For gated features: if pro, runs handler; otherwise presents paywall.
    func gateFeature(placement: String, handler: @escaping () -> Void) {
        if effectiveIsPro {
            handler()
            return
        }
        presentPaywall(placement: placement)
    }

    /// For pro-gated features: if pro, runs handler; otherwise shows feature preview disclaimer first, then paywall on dismiss.
    /// Use for Learn by Topics, Smart Learning, Favorites, Test Simulation so free users understand what they're unlocking.
    func gateFeatureWithPreview(
        placement: String,
        titleKey: String,
        messageKey: String,
        accentColorName: String,
        handler: @escaping () -> Void
    ) {
        if effectiveIsPro {
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

    /// Dismisses the feature preview sheet without showing paywall (e.g. if user became pro).
    func dismissFeaturePreviewSheet() {
        showFeaturePreviewSheet = false
        featurePreviewContent = nil
    }

    /// Shows the feature preview sheet for a limit-reached scenario (e.g. 30 SR questions, 5 favorites). On dismiss, presents paywall.
    func presentProLimitSheet(titleKey: String, messageKey: String, accentColorName: String) {
        guard !effectiveIsPro else { return }
        featurePreviewContent = FeaturePreviewContent(
            titleKey: titleKey,
            messageKey: messageKey,
            accentColorName: accentColorName
        )
        showFeaturePreviewSheet = true
    }

    private func applyCustomerInfo(_ customerInfo: CustomerInfo, activeOverride: Bool? = nil) {
        let entitlement = customerInfo.entitlements.all[entitlementId]
        let isActive = activeOverride ?? (entitlement?.isActive == true)
        isPro = isActive
        lastKnownPremiumState = isActive
        guard isActive, let entitlement else {
            tariffState = .free
            tariffRenewalDate = nil
            activeProductIdentifier = nil
            appStorePlanDisplayName = nil
            return
        }

        let productIdentifier = entitlement.productIdentifier
        let loweredProductIdentifier = productIdentifier.lowercased()
        activeProductIdentifier = productIdentifier
        tariffRenewalDate = entitlement.expirationDate
        Task {
            await refreshAppStorePlanDisplayName(for: productIdentifier)
        }

        if loweredProductIdentifier.contains("lifetime") {
            tariffState = .lifetime
        } else if entitlement.periodType == .trial {
            tariffState = .trial
        } else {
            tariffState = .subscription
        }
    }

    private func applyCachedCustomerInfoIfAvailable() {
        guard Purchases.isConfigured, let cachedCustomerInfo = Purchases.shared.cachedCustomerInfo else {
            return
        }
        applyCustomerInfo(cachedCustomerInfo, activeOverride: cachedCustomerInfo.entitlements.all[entitlementId]?.isActive == true)
    }

    private func refreshAppStorePlanDisplayName(for productIdentifier: String?) async {
        guard let productIdentifier, !productIdentifier.isEmpty else {
            appStorePlanDisplayName = nil
            return
        }
        do {
            let products = try await Product.products(for: [productIdentifier])
            appStorePlanDisplayName = products.first?.displayName
        } catch {
            appStorePlanDisplayName = nil
        }
    }
}
