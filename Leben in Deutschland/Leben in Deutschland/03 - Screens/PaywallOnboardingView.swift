//
//  PaywallOnboardingView.swift
//  Leben in Deutschland
//
//  Paywall for onboarding flow. Same UI and logic as PaywallView; not wired yet.
//

import SwiftUI
import RevenueCat
import StoreKit
import Combine
import UIKit

// MARK: - Paywall Onboarding View
/// Paywall for onboarding: fetches RevenueCat offerings, displays packages, handles purchase, restore, and redeem.
struct PaywallOnboardingView: View {
    /// When provided (onboarding flow), called instead of dismiss when user proceeds. When nil, uses dismiss.
    var onProceedToNext: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    @State private var packages: [Package] = []
    @State private var selectedPackage: Package?
    @State private var isLoading = true
    @State private var isPurchasing = false
    @State private var restoreMessage: String?
    @State private var activeLegalURL: URL?
    @State private var loadError: String?
    @State private var showRedeemSheet = false
    @State private var countdownString: String = ""
    @State private var hasRefreshedAfterExpiry = false
    @State private var standardLifetimePriceString: String?

    private static let termsURL = AppURLs.termsOfUse
    private static let privacyURL = AppURLs.privacyPolicy

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: layoutMetrics.adaptive(28)) {
                    headerSection
                    if isLoading {
                        progressView
                    } else if let error = loadError {
                        errorView(message: error)
                    } else {
                        plansSection
                        subscribeButton
                        restoreSection
                        legalSection
                    }
                }
                .padding(.horizontal, layoutMetrics.adaptive(24))
                .padding(.top, layoutMetrics.adaptive(16))
                .padding(.bottom, layoutMetrics.adaptive(40))
            }
            .background(
                Rectangle()
                    .fill(LiquidGlassGradient.blue.screenBackground)
                    .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        HapticManager.shared.lightImpact()
                        proceedToNext()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("paywall_close".localized)
                    .accessibilityHint("paywall_close_hint".localized)
                }
            }
        }
        .sheet(
            isPresented: Binding(
                get: { activeLegalURL != nil },
                set: { if !$0 { activeLegalURL = nil } }
            )
        ) {
            if let url = activeLegalURL {
                SafariSheetView(url: url)
            }
        }
        .offerCodeRedemption(isPresented: $showRedeemSheet) { _ in
            Task { await subscriptionManager.refreshProStatus() }
        }
        .onAppear {
            countdownString = LaunchOfferService.formattedCountdown(from: LaunchOfferService.secondsRemaining)
            Task { await fetchOfferings() }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            let remaining = LaunchOfferService.secondsRemaining
            countdownString = LaunchOfferService.formattedCountdown(from: remaining)
            if remaining <= 0, !hasRefreshedAfterExpiry {
                hasRefreshedAfterExpiry = true
                Task { await fetchOfferings() }
            }
        }
    }

    // MARK: - Header (pro badge, title, trial line, mascot)
    private var headerSection: some View {
        VStack(spacing: layoutMetrics.adaptive(12)) {
            ProBadge(color: .white, showShimmer: true)

            Text("paywall_onboarding_title".localized)
                .font(.system(.title3, weight: .heavy).italic())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("paywall_trial_line".localized)
                .font(Font(UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .medium, width: .condensed)))
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)

            PaywallOnboardingMascotImage()
                .frame(width: layoutMetrics.adaptive(130), height: layoutMetrics.adaptive(130))
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, layoutMetrics.adaptive(8))
    }

    private var progressView: some View {
        VStack(spacing: layoutMetrics.adaptive(16)) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, layoutMetrics.adaptive(40))
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: layoutMetrics.adaptive(12)) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: layoutMetrics.adaptive(40)))
                .foregroundStyle(.white.opacity(0.9))
            Text(message)
                .font(.system(.subheadline))
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, layoutMetrics.adaptive(40))
    }

    // MARK: - Plans
    private var plansSection: some View {
        VStack(spacing: layoutMetrics.adaptive(18)) {
            ForEach(packages, id: \.identifier) { package in
                PaywallPackageRow(
                    package: package,
                    isSelected: selectedPackage?.identifier == package.identifier,
                    onSelect: {
                        HapticManager.shared.lightImpact()
                        selectedPackage = package
                    },
                    countdownText: (package.identifier == LaunchOfferService.promoPackageIdentifier && LaunchOfferService.isLaunchOfferActive) ? countdownString : nil,
                    showLaunchOfferBadge: package.identifier == LaunchOfferService.promoPackageIdentifier && LaunchOfferService.isLaunchOfferActive,
                    showBestValueBadge: package.packageType == .threeMonth && !LaunchOfferService.isLaunchOfferActive,
                    strikethroughPrice: (package.identifier == LaunchOfferService.promoPackageIdentifier && LaunchOfferService.isLaunchOfferActive) ? standardLifetimePriceString : nil
                )
                .id(package.identifier)
            }
        }
    }

    // MARK: - Subscribe Button (blue gradient, same as All Questions Next button)
    private var subscribeButton: some View {
        let isActive = selectedPackage != nil && !isPurchasing
        let style = QuizActionButton.Style(
            backgroundColor: Color("AppBlueLagoon"),
            disabledBackgroundColor: Color(.systemGray2),
            haloPrimaryColor: Color("AppBlueLagoon").opacity(0.36),
            haloSecondaryColor: Color.white.opacity(0.18),
            suppressGlow: true,
            gradient: .blue
        )
        return VStack(spacing: layoutMetrics.adaptive(20)) {
            QuizActionButton(
                "pro_continue".localized.uppercased(),
                style: style,
                isEnabled: isActive,
                accessibilityLabel: "pro_continue".localized
            ) {
                HapticManager.shared.mediumImpact()
                performPurchase()
            }
            .frame(maxWidth: .infinity)

            Button {
                HapticManager.shared.lightImpact()
                proceedToNext()
            } label: {
                Text("paywall_onboarding_maybe_later".localized)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("paywall_onboarding_maybe_later".localized)
        }
    }

    // MARK: - Restore
    private var restoreSection: some View {
        VStack(spacing: layoutMetrics.adaptive(8)) {
            Button(action: restorePurchases) {
                Text("paywall_restore".localized)
                    .font(.system(.footnote, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .disabled(isPurchasing)
            .accessibilityLabel("paywall_restore".localized)
            .accessibilityHint("paywall_restore_hint".localized)

            if let message = restoreMessage {
                Text(message)
                    .font(.system(.caption))
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Legal (boilerplate + Redeem · Terms · Privacy on one row)
    private var legalSection: some View {
        VStack(spacing: layoutMetrics.adaptive(12)) {
            paywallTermsText

            HStack(spacing: layoutMetrics.adaptive(8)) {
                Button(action: { activeLegalURL = PaywallOnboardingView.termsURL }) {
                    Text("paywall_terms".localized)
                        .font(.system(.caption2, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .accessibilityLabel("paywall_terms".localized)
                .accessibilityHint("paywall_terms_hint".localized)

                Text("·")
                    .font(.system(.caption2))
                    .foregroundStyle(.white.opacity(0.7))

                Button(action: { activeLegalURL = PaywallOnboardingView.privacyURL }) {
                    Text("paywall_privacy".localized)
                        .font(.system(.caption2, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .accessibilityLabel("paywall_privacy".localized)
                .accessibilityHint("paywall_privacy_hint".localized)

                Text("·")
                    .font(.system(.caption2))
                    .foregroundStyle(.white.opacity(0.7))

                Button(action: presentRedeemCodeSheet) {
                    Text("paywall_redeem".localized)
                        .font(.system(.caption2, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .accessibilityLabel("paywall_redeem".localized)
                .accessibilityHint("paywall_redeem_hint".localized)
            }
        }
    }

    private var paywallTermsText: some View {
        Text("paywall_terms_boilerplate".localized)
            .font(.system(.caption2))
            .foregroundStyle(.white.opacity(0.8))
            .multilineTextAlignment(.center)
    }

    // MARK: - Data Fetching
    private func fetchOfferings() async {
        guard Purchases.isConfigured else {
            await MainActor.run {
                loadError = "RevenueCat not configured"
                isLoading = false
            }
            return
        }
        await MainActor.run { isLoading = true; loadError = nil }

        do {
            let offerings = try await Purchases.shared.offerings()
            guard let offering = offerings.current else {
                await MainActor.run {
                    loadError = "No offerings available"
                    isLoading = false
                }
                return
            }
            let available = offering.availablePackages
            let standardLifetime = available.first { $0.storeProduct.productIdentifier == LaunchOfferService.standardLifetimeProductId }
            let standardPrice = standardLifetime?.formattedPriceString
            let filtered = filterPackagesForLaunchOffer(available)
            await MainActor.run {
                standardLifetimePriceString = standardPrice
                packages = filtered
                selectedPackage = filtered.first { $0.packageType == .threeMonth }
                    ?? filtered.first { $0.identifier == LaunchOfferService.promoPackageIdentifier }
                    ?? filtered.first { $0.packageType == .lifetime }
                    ?? filtered.first
                isLoading = false
            }
        } catch {
            await MainActor.run {
                loadError = error.localizedDescription
                isLoading = false
            }
        }
    }

    /// Applies Launch Offer logic: within 3 days show promo in place of standard lifetime (3 buttons total).
    /// After 3 days, show standard lifetime only. Never show both lifetime and promo.
    private func filterPackagesForLaunchOffer(_ available: [Package]) -> [Package] {
        let promo = available.first { $0.identifier == LaunchOfferService.promoPackageIdentifier }

        if LaunchOfferService.isLaunchOfferActive, let promoPackage = promo {
            // Remove both promo and standard lifetime, then add promo → single "Lifetime" slot with strikethrough.
            var result = available.filter {
                $0.identifier != LaunchOfferService.promoPackageIdentifier &&
                $0.storeProduct.productIdentifier != LaunchOfferService.standardLifetimeProductId
            }
            result.append(promoPackage)
            return result
        } else {
            return available.filter { $0.identifier != LaunchOfferService.promoPackageIdentifier }
        }
    }

    // MARK: - Actions
    private func performPurchase() {
        guard let package = selectedPackage else { return }
        HapticManager.shared.mediumImpact()
        isPurchasing = true
        restoreMessage = nil
        Task {
            do {
                let result = try await Purchases.shared.purchase(package: package)
                if !result.userCancelled {
                    await subscriptionManager.refreshProStatus()
                }
                await MainActor.run {
                    isPurchasing = false
                    if !result.userCancelled {
                        proceedToNext()
                    }
                }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                    restoreMessage = error.localizedDescription
                }
            }
        }
    }

    private func restorePurchases() {
        HapticManager.shared.lightImpact()
        isPurchasing = true
        restoreMessage = nil
        Task {
            do {
                _ = try await Purchases.shared.restorePurchases()
                await subscriptionManager.refreshProStatus()
                await MainActor.run {
                    isPurchasing = false
                    if subscriptionManager.effectiveIsPro {
                        restoreMessage = "paywall_restore_success".localized
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            proceedToNext()
                        }
                    } else {
                        restoreMessage = "paywall_restore_no_subscription".localized
                    }
                }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                    restoreMessage = error.localizedDescription
                }
            }
        }
    }

    private func presentRedeemCodeSheet() {
        HapticManager.shared.lightImpact()
        showRedeemSheet = true
    }

    private func proceedToNext() {
        if let action = onProceedToNext {
            action()
        } else {
            dismiss()
        }
    }
}

// MARK: - Paywall Onboarding Mascot Image
private struct PaywallOnboardingMascotImage: View {
    @Environment(\.colorScheme) private var colorScheme

    private var assetName: String {
        if colorScheme == .dark, UIImage(named: "MainChick_AboutDark") != nil {
            return "MainChick_AboutDark"
        }
        return "MainChick_About"
    }

    var body: some View {
        Image(assetName)
            .resizable()
            .scaledToFit()
            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Preview
#Preview("Paywall Onboarding") {
    PaywallOnboardingView()
        .environmentObject(SubscriptionManager.shared)
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
