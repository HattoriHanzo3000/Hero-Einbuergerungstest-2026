import SwiftUI

// MARK: - Onboarding Next Button Component
struct OnboardingNextButtonComponent: View {
    let isEnabled: Bool
    let action: () -> Void
    let showBackButton: Bool
    let backAction: (() -> Void)?
    let titleKey: String
    @EnvironmentObject var languageManager: LanguageManager
    @State private var isBackPressed = false
    @State private var isNextPressed = false
    
    private let cornerRadius: CGFloat = 12
    private let buttonHeight: CGFloat = 56
    
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
    
    var body: some View {
        HStack(spacing: 12) {
            if showBackButton {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    backAction?()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.bold())
                        .fontDesign(.rounded)
                        .foregroundColor(Color(.systemGray6))
                        .frame(width: buttonHeight, height: buttonHeight)
                        .background(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(Color("AppOrange"))
                        )
                }
                .accessibilityLabel("Back")
                .accessibilityHint("Go back to previous step")
                .scaleEffect(isBackPressed ? 0.98 : 1.0)
                .buttonPressAnimation(isPressed: $isBackPressed)
            }
            
            Button(action: {
                if isEnabled {
                    HapticManager.shared.mediumImpact()
                    action()
                }
            }) {
                Text(titleKey.localized)
                    .font(.title3.bold())
                    .fontDesign(.rounded)
                    .foregroundColor(Color(.systemGray6))
                    .frame(maxWidth: .infinity)
                    .frame(height: buttonHeight)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(isEnabled ? Color("AppOrange") : Color.gray)
                    )
                    .id(languageManager.currentAppLanguage)
            }
            .disabled(!isEnabled)
            .frame(maxWidth: .infinity)
            .scaleEffect(isNextPressed ? 0.98 : 1.0)
            .buttonPressAnimation(isPressed: $isNextPressed)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
        .background(Color(.systemBackground))
    }
}
