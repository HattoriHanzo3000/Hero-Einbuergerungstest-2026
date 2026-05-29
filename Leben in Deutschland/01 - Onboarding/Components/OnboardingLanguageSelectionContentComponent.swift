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

// MARK: - Language Option Row (QuizAnswerOptionButton style)
private struct OnboardingLanguageOptionRowComponent: View {
    let language: LanguageOption
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        QuizAnswerOptionButton(
            primaryText: language.name,
            state: isSelected ? .selected : .neutral,
            suppressGlow: true,
            action: onTap
        )
    }
}
