//
//  EagleLevelUpView.swift
//  Leben in Deutschland
//
//  Splash shown when user reaches a new eagle readiness stage.
//

import SwiftUI

// MARK: - Eagle Level Up View
struct EagleLevelUpView: View {
    let stage: EagleStage
    let readinessPercentage: Int
    let onDismiss: () -> Void

    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var confettiActive = false
    private var stageMessage: String {
        ReadinessMessageHelper.message(
            readinessPercentage: readinessPercentage,
            languageCode: languageManager.currentAppLanguage
        )
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(LiquidGlassGradient.blue.screenBackground)
                .ignoresSafeArea()

            if confettiActive {
                ConfettiOverlay(isActive: true)
                    .zIndex(2)
            }

            VStack(spacing: layoutMetrics.adaptive(24)) {
                Spacer()

                // Trophy icon (gold/amber, shimmer)
                Image(systemName: "trophy.fill")
                    .font(.system(size: layoutMetrics.adaptive(48), weight: .semibold))
                    .foregroundColor(Color("AppAmber"))
                    .overlay(
                        ShimmerOverlay(duration: 3)
                            .mask(
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: layoutMetrics.adaptive(48), weight: .semibold))
                            )
                            .blendMode(.plusLighter)
                    )
                    .accessibilityHidden(true)

                // Title with shimmer (static)
                levelUpTitleView
                    .accessibilityAddTraits(.isHeader)

                // Stage message
                Text(stageMessage)
                    .font(.system(.title3, weight: .semibold).italic())
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, layoutMetrics.adaptive(24))
                    .fixedSize(horizontal: false, vertical: true)

                // Mascot
                MascotView(autoPlayInterval: 4)
                    .frame(width: layoutMetrics.adaptive(140), height: layoutMetrics.adaptive(140))

                Spacer()

                // Continue button (matches SpacedRepetition Check/Next: liquid glass, AppBlueLagoon, caps)
                QuizActionButton(
                    "eagle_level_up_continue".localized.uppercased(),
                    style: QuizActionButton.Style(
                        backgroundColor: Color("AppBlueLagoon"),
                        disabledBackgroundColor: Color(.systemGray2),
                        haloPrimaryColor: Color("AppBlueLagoon").opacity(0.36),
                        haloSecondaryColor: Color.white.opacity(0.18),
                        suppressGlow: true,
                        gradient: .blue
                    )
                ) {
                    HapticManager.shared.lightImpact()
                    EagleLevelUpService.markStageSeen(stage)
                    onDismiss()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, layoutMetrics.adaptive(LayoutMetrics.footerHorizontalPadding))
                .padding(.bottom, layoutMetrics.adaptive(40))
                .accessibilityLabel("eagle_level_up_continue".localized)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("eagle_level_up_title".localized)
        .accessibilityHint(stageMessage)
        .onAppear {
            triggerConfettiIfNeeded()
        }
    }

    @ViewBuilder
    private var levelUpTitleView: some View {
        let title = "eagle_level_up_title".localized + "!"
        let font = Font.system(.title, weight: .heavy).width(.expanded)
        Text(title)
            .font(font)
            .foregroundColor(Color("AppAmber"))
            .overlay(
                ShimmerOverlay(duration: 3)
                    .mask(Text(title).font(font))
                    .blendMode(.plusLighter)
            )
    }

    private func triggerConfettiIfNeeded() {
        guard !reduceMotion else { return }
        guard !confettiActive else { return }

        confettiActive = true
        HapticManager.shared.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + ConfettiOverlay.overlayRemovalDelay) {
            confettiActive = false
        }
    }
}

// MARK: - Preview
#Preview("Eagle Level Up – Chick") {
    EagleLevelUpView(
        stage: .chick,
        readinessPercentage: 12,
        onDismiss: {}
    )
    .environmentObject(LanguageManager())
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
