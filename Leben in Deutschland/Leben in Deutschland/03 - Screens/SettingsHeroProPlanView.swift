import SwiftUI
import StoreKit
import UIKit

struct SettingsHeroProPlanView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @State private var showManageSubscriptionFailed = false
    @State private var showOfferCodeRedemption = false

    var body: some View {
        ZStack {
            HeroProPaywallBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    heroSection
                    actionSection
                    Spacer(minLength: 24)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("hero_pro_nav_title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await subscriptionManager.refreshPremiumStatus()
        }
        .alert("hero_pro_manage_subscription_failed_title".localized, isPresented: $showManageSubscriptionFailed) {
            Button("ok".localized, role: .cancel) { }
        } message: {
            Text("hero_pro_manage_subscription_failed_message".localized)
        }
        .alert("paywall_restore".localized, isPresented: $subscriptionManager.showRestoreFeedbackAlert) {
            Button("ok".localized, role: .cancel) {
                subscriptionManager.dismissRestoreFeedbackAlert()
            }
        } message: {
            Text(subscriptionManager.restoreFeedbackMessage ?? "")
        }
        .offerCodeRedemption(isPresented: $showOfferCodeRedemption) { result in
            if case .success = result {
                Task {
                    await subscriptionManager.refreshPremiumStatus()
                }
            }
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HeroProMascotImage()
                .frame(maxWidth: 200, maxHeight: 200)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)

            if subscriptionManager.effectiveIsPremium {
                HeroProShieldBadge(
                    label: "settings_premium_title".localized,
                    showShimmer: true
                )
                    .frame(maxWidth: .infinity)
            }

            Text(subscriptionManager.localizedPlanStatusLine)
                .font(.title.weight(.semibold))
                .italic()
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)

            Text(subscriptionManager.localizedPlanDetailBody)
                .font(.body)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)

            if let dateLine = subscriptionManager.localizedPlanDateLine {
                Text(dateLine)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let thanksLine = subscriptionManager.localizedPlanLifetimeThanks {
                Text(thanksLine)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var actionSection: some View {
        VStack(spacing: 0) {
            if subscriptionManager.showsManageSubscriptionAction {
                Button {
                    HapticManager.shared.lightImpact()
                    openManageSubscriptions()
                } label: {
                    Text("hero_pro_manage_subscription".localized)
                        .font(.system(.footnote, design: .default).weight(.semibold))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
                .padding(.bottom, 4)
            }

            if subscriptionManager.showsViewPlansAction {
                HeroProPrimaryButton(
                    title: "hero_pro_view_plans".localized,
                    isLoading: false,
                    isEnabled: true,
                    horizontalPadding: 8
                ) {
                    HapticManager.shared.lightImpact()
                    subscriptionManager.presentPaywall(placement: "settings_hero_pro_plan")
                }
                .padding(.top, subscriptionManager.showsManageSubscriptionAction ? 20 : 10)
                .padding(.bottom, 18)
            }

            VStack(spacing: 14) {
                if subscriptionManager.showsRestoreAction {
                    HeroProFooterLinkBlock(
                        caption: "hero_pro_restore_caption".localized,
                        actionTitle: "paywall_restore".localized,
                        horizontalPadding: 8
                    ) {
                        HapticManager.shared.lightImpact()
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    }
                }

                if subscriptionManager.showsRedeemAction {
                    HeroProFooterLinkBlock(
                        caption: "hero_pro_redeem_caption".localized,
                        actionTitle: "paywall_redeem".localized,
                        horizontalPadding: 8
                    ) {
                        HapticManager.shared.lightImpact()
                        showOfferCodeRedemption = true
                    }
                }
            }
            .padding(.top, (subscriptionManager.showsRestoreAction || subscriptionManager.showsRedeemAction) ? 28 : 0)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }

    private func openManageSubscriptions() {
        Task { @MainActor in
            let ok = await ManageSubscriptionsPresenter.presentSystemManageSubscriptions()
            if !ok {
                showManageSubscriptionFailed = true
            }
        }
    }
}

private struct HeroProPaywallBackground: View {
    var body: some View {
        Rectangle()
            .fill(LiquidGlassGradient.blue.screenBackground)
            .ignoresSafeArea()
    }
}

private struct HeroProPrimaryButton: View {
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    var horizontalPadding: CGFloat = 24
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            let shape = RoundedRectangle(cornerRadius: 28, style: .continuous)
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Spacer()
                    Text(title.uppercased())
                        .font(.system(.headline, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.85)
                        .allowsTightening(true)
                    Spacer()
                }
            }
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(
                shape
                    .fill(
                        LinearGradient(
                            colors: [Color("AppBurgundy"), Color("AppBurgundy").opacity(0.78)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(isEnabled ? 1.0 : 0.75)
                    .overlay(shape.stroke(Color.white.opacity(0.12), lineWidth: 0.4).blendMode(.plusLighter))
                    .overlay(shape.stroke(Color.white.opacity(0.18), lineWidth: 1))
            )
            .clipShape(shape)
            .shadow(color: .black.opacity(isEnabled ? 0.16 : 0.08), radius: 22, x: 0, y: 10)
            .scaleEffect(isEnabled ? 1 : 0.98)
            .animation(.spring(response: 0.45, dampingFraction: 0.82), value: isEnabled)
        }
        .disabled(!isEnabled)
        .padding(.horizontal, horizontalPadding)
        .background(Color.clear)
    }
}

private struct HeroProFooterLinkBlock: View {
    let caption: String
    let actionTitle: String
    var horizontalPadding: CGFloat = 24
    let action: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            Text(caption)
                .font(.system(.footnote, design: .default).weight(.medium))
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)
            Button(actionTitle, action: action)
                .font(.system(.footnote, design: .default).weight(.semibold))
                .foregroundStyle(Color("AppBurgundy"))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, horizontalPadding)
    }
}

private struct HeroProShieldBadge: View {
    let label: String
    var showShimmer: Bool = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = 0

    var body: some View {
        Text(label.uppercased())
            .font(.system(.caption2, weight: .medium).width(.expanded))
            .foregroundColor(.white)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(.white, lineWidth: 0.6)
            )
            .overlay {
                if showShimmer && !reduceMotion {
                    GeometryReader { geo in
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.62), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geo.size.width * 0.5)
                        .offset(x: phase * geo.size.width * 1.8 - geo.size.width * 0.5)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .blendMode(.plusLighter)
                        .onAppear {
                            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                                phase = 1
                            }
                        }
                    }
                }
            }
            .compositingGroup()
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .accessibilityHidden(true)
    }
}

private struct HeroProMascotImage: View {
    private var assetName: String {
        if UIImage(named: "Mascot") != nil {
            return "Mascot"
        }
        if UIImage(named: "MainChick_About") != nil {
            return "MainChick_About"
        }
        return "MainChick_AboutDark"
    }

    var body: some View {
        Image(assetName)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

#Preview("Hero Pro Plan") {
    NavigationStack {
        SettingsHeroProPlanView()
            .environmentObject(SubscriptionManager.shared)
    }
}
