//
//  PaywallView.swift
//  Leben in Deutschland
//
//  SwiftUI paywall using RevenueCat for offerings, purchases, restore, and redeem.
//  Replaces Superwall with native UI per Apple's guidelines.
//

import SwiftUI
import RevenueCat
import StoreKit

// MARK: - Paywall View
/// Paywall sheet: fetches RevenueCat offerings, displays packages, handles purchase, restore, and redeem.
struct PaywallView: View {
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
                        dismiss()
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
            Task { await subscriptionManager.refreshPremiumStatus() }
        }
        .onAppear {
            Task { await fetchOfferings() }
        }
    }

    // MARK: - Header (premium badge top right, like Categories)
    private var headerSection: some View {
        VStack(spacing: layoutMetrics.adaptive(12)) {
            PremiumBadge(color: .white, showShimmer: true)

            Text("paywall_title".localized)
                .font(.system(.title2, weight: .heavy).italic())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("paywall_trial_line".localized)
                .font(.system(.footnote, weight: .heavy))
                .foregroundStyle(.white.opacity(0.95))
                .multilineTextAlignment(.center)

            PaywallMascotImage()
                .frame(width: layoutMetrics.adaptive(130), height: layoutMetrics.adaptive(130))
                .accessibilityHidden(true)

            Text("paywall_subtitle".localized)
                .font(.system(.subheadline))
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
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
                    }
                )
                .id(package.identifier)
            }
        }
    }

    // MARK: - Subscribe Button (same shape and style as Finish in test simulation: orange, caps)
    private var subscribeButton: some View {
        let isActive = selectedPackage != nil && !isPurchasing
        let style = QuizActionButton.Style(
            backgroundColor: Color("AppOrange"),
            disabledBackgroundColor: Color(.systemGray2),
            haloPrimaryColor: Color("AppOrange").opacity(0.36),
            haloSecondaryColor: Color.white.opacity(0.18),
            suppressGlow: true,
            gradient: .orange
        )
        return QuizActionButton(
            "premium_continue".localized.uppercased(),
            style: style,
            isEnabled: isActive,
            accessibilityLabel: "premium_continue".localized
        ) {
            HapticManager.shared.mediumImpact()
            performPurchase()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Restore
    private var restoreSection: some View {
        VStack(spacing: layoutMetrics.adaptive(8)) {
            Button(action: restorePurchases) {
                Text("paywall_restore".localized)
                    .font(.system(.subheadline, weight: .medium))
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
                Button(action: { activeLegalURL = PaywallView.termsURL }) {
                    Text("paywall_terms".localized)
                        .font(.system(.caption2, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .accessibilityLabel("paywall_terms".localized)
                .accessibilityHint("paywall_terms_hint".localized)

                Text("·")
                    .font(.system(.caption2))
                    .foregroundStyle(.white.opacity(0.7))

                Button(action: { activeLegalURL = PaywallView.privacyURL }) {
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
            await MainActor.run {
                packages = available
                selectedPackage = available.first { $0.packageType == .threeMonth } ?? available.first
                isLoading = false
            }
        } catch {
            await MainActor.run {
                loadError = error.localizedDescription
                isLoading = false
            }
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
                    await subscriptionManager.refreshPremiumStatus()
                }
                await MainActor.run {
                    isPurchasing = false
                    if !result.userCancelled {
                        dismiss()
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
                await subscriptionManager.refreshPremiumStatus()
                await MainActor.run {
                    isPurchasing = false
                    if subscriptionManager.isPremium {
                        restoreMessage = "paywall_restore_success".localized
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            dismiss()
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
}

// MARK: - Paywall Mascot Image
/// Main chick mascot for paywall header. Uses MainChick_About light asset.
private struct PaywallMascotImage: View {
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
#Preview("Paywall") {
    PaywallView()
        .environmentObject(SubscriptionManager.shared)
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
