import SwiftUI

// MARK: - Onboarding Language Selection Content Component
struct OnboardingLanguageSelectionContentComponent: View {
    @Binding var selectedLanguage: String?
    let onLanguageSelected: (String) -> Void
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    var body: some View {
        VStack(spacing: OnboardingConstants.defaultSpacing) {
            ForEach(LanguageOption.availableLanguages) { language in
                OnboardingLanguageOptionRowComponent(
                    language: language,
                    isSelected: selectedLanguage == language.name,
                    onTap: {
                        HapticManager.shared.lightImpact()
                        onLanguageSelected(language.name)
                    }
                )
            }
        }
        .frame(width: layoutMetrics.screenWidth * OnboardingConstants.buttonWidthRatio)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 16)
        .padding(.horizontal, 4)
    }
}

// MARK: - Language Option Row (press animated)
private struct OnboardingLanguageOptionRowComponent: View {
    let language: LanguageOption
    let isSelected: Bool
    let onTap: () -> Void
    
    private var selectedFill: Color { Color.accentColor }
    private var unselectedFill: Color { Color("Unselected") }
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            Text(language.name)
                .font(.body)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 56)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? selectedFill : unselectedFill)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .buttonPressAnimation(isPressed: $isPressed)
    }
}
