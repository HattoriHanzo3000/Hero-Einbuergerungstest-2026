import SwiftUI

// MARK: - Onboarding Next Button Component
/// Matches SpacedRepetitionQuestionCard footer: QuizActionButton for Next, back arrow with same radius (28).
struct OnboardingNextButtonComponent: View {
    let isEnabled: Bool
    let action: () -> Void
    let showBackButton: Bool
    let backAction: (() -> Void)?
    let titleKey: String
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    init(
        isEnabled: Bool,
        action: @escaping () -> Void,
        showBackButton: Bool = false,
        backAction: (() -> Void)? = nil,
        titleKey: String = "NEXT"
    ) {
        self.isEnabled = isEnabled
        self.action = action
        self.showBackButton = showBackButton
        self.backAction = backAction
        self.titleKey = titleKey
    }
    
    private var nextButtonStyle: QuizActionButton.Style {
        QuizActionButton.Style(
            backgroundColor: Color("AppOrange"),
            disabledBackgroundColor: Color(.systemGray2),
            haloPrimaryColor: Color("AppOrange").opacity(0.36),
            haloSecondaryColor: Color.white.opacity(0.18),
            showsHaloWhenDisabled: false,
            suppressGlow: true
        )
    }
    
    var body: some View {
        HStack(spacing: layoutMetrics.adaptive(12)) {
            if showBackButton, let backAction = backAction {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    backAction()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: layoutMetrics.adaptive(20), weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, layoutMetrics.adaptive(18))
                        .frame(width: layoutMetrics.adaptive(80))
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(28), style: .continuous)
                                    .fill(.ultraThinMaterial)
                                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(28), style: .continuous)
                                    .fill(Color("AppOrange"))
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(28), style: .continuous)
                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                            )
                        )
                        .shadow(
                            color: Color.black.opacity(0.16),
                            radius: layoutMetrics.adaptive(22),
                            y: layoutMetrics.adaptive(10)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("back_button_accessibility_label".localized)
                .accessibilityHint("Go back to previous step")
                .accessibilityAddTraits(.isButton)
            }
            
            QuizActionButton(
                titleKey.localized(for: languageManager.currentAppLanguage),
                style: nextButtonStyle,
                isEnabled: isEnabled,
                accessibilityLabel: titleKey.localized(for: languageManager.currentAppLanguage)
            ) {
                if isEnabled {
                    HapticManager.shared.mediumImpact()
                    action()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, layoutMetrics.adaptive(24))
        .padding(.top, layoutMetrics.adaptive(12))
        .padding(.bottom, layoutMetrics.adaptive(24))
        .background(Color(.systemBackground))
        .id(languageManager.currentAppLanguage)
    }
}
