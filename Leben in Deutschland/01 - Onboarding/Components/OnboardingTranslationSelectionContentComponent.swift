import SwiftUI

// MARK: - Onboarding Translation Language Selection Component
struct OnboardingTranslationSelectionContentComponent: View {
    @Binding var selectedLanguage: String?
    let onLanguageSelected: (String) -> Void
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    var body: some View {
        VStack(spacing: OnboardingConstants.defaultSpacing) {
            ForEach(LanguageOption.availableLanguages) { language in
                OnboardingTranslationLanguageOptionRowComponent(
                    language: language,
                    isSelected: selectedLanguage == language.name,
                    isDisabled: isSameAsAppLanguage(languageName: language.name),
                    onTap: {
                        if !isSameAsAppLanguage(languageName: language.name) {
                            HapticManager.shared.lightImpact()
                            onLanguageSelected(language.name)
                        }
                    }
                )
            }
        }
        .transaction { t in t.animation = nil }
        .frame(width: layoutMetrics.screenWidth * OnboardingConstants.buttonWidthRatio)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 16)
        .padding(.horizontal, 4)
    }
    
    private func isSameAsAppLanguage(languageName: String) -> Bool {
        let languageCode = LanguageOption.getLanguageCode(for: languageName)
        return languageCode == languageManager.currentAppLanguage
    }
}

// MARK: - Translation Language Option Row (QuizAnswerOptionButton style)
private struct OnboardingTranslationLanguageOptionRowComponent: View {
    let language: LanguageOption
    let isSelected: Bool
    let isDisabled: Bool
    let onTap: () -> Void
    
    var body: some View {
        QuizAnswerOptionButton(
            primaryText: language.name,
            state: isSelected ? .selected : .neutral,
            isEnabled: !isDisabled,
            suppressGlow: true,
            action: onTap
        )
        .opacity(isDisabled ? 0.6 : 1)
    }
}
