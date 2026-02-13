//
//  PaywallView.swift
//  Leben in Deutschland
//
//  Simple first paywall per Apple's guidelines: clear pricing, Restore,
//  Terms of Use and Privacy Policy. Opens when user taps the crown.
//

import SwiftUI

// MARK: - Paywall View
/// First paywall sheet: monthly €1.99, yearly €14.99, with Restore and legal links.
struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutMetrics) private var layoutMetrics
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var premiumManager: PremiumManager
    
    @State private var selectedPlan: SubscriptionPlanType? = .yearly
    @State private var isPurchasing = false
    @State private var restoreMessage: String?
    
    private static let termsURL = AppURLs.termsOfUse
    private static let privacyURL = AppURLs.privacyPolicy
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: layoutMetrics.adaptive(28)) {
                    headerSection
                    plansSection
                    subscribeButton
                    restoreSection
                    legalSection
                }
                .padding(.horizontal, layoutMetrics.adaptive(24))
                .padding(.top, layoutMetrics.adaptive(16))
                .padding(.bottom, layoutMetrics.adaptive(40))
            }
            .background(Color(.systemBackground))
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
        .onAppear {
            if selectedPlan == nil { selectedPlan = .yearly }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: layoutMetrics.adaptive(12)) {
            Image(systemName: "crown.fill")
                .font(.system(size: layoutMetrics.adaptive(52), weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color("AppOrange"), Color(red: 0.77, green: 0.21, blue: 0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .accessibilityHidden(true)
            
            Text("paywall_title".localized)
                .font(.system(.title2, design: .rounded).weight(.bold).width(.condensed))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
            
            Text("paywall_subtitle".localized)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, layoutMetrics.adaptive(8))
    }
    
    // MARK: - Plans
    private var plansSection: some View {
        VStack(spacing: layoutMetrics.adaptive(12)) {
            PaywallPlanRow(
                plan: .monthlyPlan,
                isSelected: selectedPlan == .monthly,
                onSelect: {
                    HapticManager.shared.lightImpact()
                    selectedPlan = .monthly
                }
            )
            PaywallPlanRow(
                plan: .yearlyPlan,
                isSelected: selectedPlan == .yearly,
                onSelect: {
                    HapticManager.shared.lightImpact()
                    selectedPlan = .yearly
                }
            )
        }
    }
    
    // MARK: - Subscribe Button
    private var subscribeButton: some View {
        Button(action: performPurchase) {
            Text("premium_continue".localized)
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: layoutMetrics.adaptive(56))
                .background(
                    LinearGradient(
                        colors: [
                            Color("AppOrange"),
                            Color(red: 0.77, green: 0.21, blue: 0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: layoutMetrics.adaptive(16), style: .continuous))
                .shadow(color: Color("AppOrange").opacity(0.3), radius: 10, y: 4)
        }
        .disabled(selectedPlan == nil || isPurchasing)
        .opacity(selectedPlan == nil ? 0.6 : 1)
    }
    
    // MARK: - Restore
    private var restoreSection: some View {
        VStack(spacing: layoutMetrics.adaptive(8)) {
            Button(action: restorePurchases) {
                Text("paywall_restore".localized)
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .disabled(isPurchasing)
            .accessibilityLabel("paywall_restore".localized)
            .accessibilityHint("paywall_restore_hint".localized)
            
            if let message = restoreMessage {
                Text(message)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Legal
    private var legalSection: some View {
        VStack(spacing: layoutMetrics.adaptive(12)) {
            paywallTermsText
            
            HStack(spacing: layoutMetrics.adaptive(20)) {
                Button(action: { openURL(PaywallView.termsURL) }) {
                    Text("paywall_terms".localized)
                        .font(.system(.caption, design: .rounded).weight(.medium))
                        .foregroundStyle(Color("AppOrange"))
                }
                .accessibilityLabel("paywall_terms".localized)
                .accessibilityHint("paywall_terms_hint".localized)
                
                Text("·")
                    .foregroundStyle(.tertiary)
                
                Button(action: { openURL(PaywallView.privacyURL) }) {
                    Text("paywall_privacy".localized)
                        .font(.system(.caption, design: .rounded).weight(.medium))
                        .foregroundStyle(Color("AppOrange"))
                }
                .accessibilityLabel("paywall_privacy".localized)
                .accessibilityHint("paywall_privacy_hint".localized)
            }
        }
    }
    
    private var paywallTermsText: some View {
        Text("paywall_terms_boilerplate".localized)
            .font(.system(.caption2, design: .rounded))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
    
    // MARK: - Actions
    private func performPurchase() {
        guard let plan = selectedPlan else { return }
        HapticManager.shared.mediumImpact()
        isPurchasing = true
        // TODO: Replace with StoreKit 2 purchase flow when products are configured in App Store Connect
        handlePurchaseSuccess(plan: plan)
    }
    
    private func handlePurchaseSuccess(plan: SubscriptionPlanType) {
        let expiry: Date?
        switch plan {
        case .monthly:
            expiry = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        case .yearly:
            expiry = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        case .lifetime:
            expiry = nil
        }
        premiumManager.activateSubscription(type: plan, expiryDate: expiry)
        isPurchasing = false
        dismiss()
    }
    
    private func restorePurchases() {
        HapticManager.shared.lightImpact()
        isPurchasing = true
        restoreMessage = nil
        // TODO: Call StoreKit 2 Transaction.currentEntitlements and sync with PremiumManager
        Task {
            try? await Task.sleep(nanoseconds: 800_000_000)
            await MainActor.run {
                premiumManager.checkPremiumStatus()
                if premiumManager.isPremium {
                    restoreMessage = "paywall_restore_success".localized
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()
                    }
                } else {
                    restoreMessage = "paywall_restore_no_subscription".localized
                }
                isPurchasing = false
            }
        }
    }
}

// MARK: - Paywall Plan Row
private struct PaywallPlanRow: View {
    let plan: SubscriptionPlanModel
    let isSelected: Bool
    let onSelect: () -> Void
    
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    private var planTitleKey: String {
        switch plan.type {
        case .monthly: return "premium_plan_monthly"
        case .yearly: return "premium_plan_yearly"
        case .lifetime: return "premium_plan_lifetime"
        }
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: layoutMetrics.adaptive(16)) {
                VStack(alignment: .leading, spacing: layoutMetrics.adaptive(4)) {
                    HStack(spacing: layoutMetrics.adaptive(8)) {
                        Text(planTitleKey.localized)
                            .font(.system(.headline, design: .rounded).weight(.bold))
                            .foregroundStyle(.primary)
                        if plan.isLimitedOffer {
                            Text("paywall_best_value".localized)
                                .font(.system(.caption2, design: .rounded).weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color("AppOrange"))
                                .clipShape(Capsule())
                        }
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(plan.price) €")
                            .font(.system(.title3, design: .rounded).weight(.bold))
                            .foregroundStyle(.primary)
                        if let periodKey = plan.periodKey {
                            Text(periodKey.localized)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                    if let subtitleKey = plan.subtitleKey {
                        Text(subtitleKey.localized)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: layoutMetrics.adaptive(24), weight: .semibold))
                    .foregroundStyle(isSelected ? Color("AppOrange") : .secondary)
            }
            .padding(layoutMetrics.adaptive(16))
            .background(
                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(16), style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(16), style: .continuous)
                            .stroke(
                                isSelected ? Color("AppOrange") : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview("Paywall") {
    PaywallView()
        .environmentObject(PremiumManager.shared)
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
