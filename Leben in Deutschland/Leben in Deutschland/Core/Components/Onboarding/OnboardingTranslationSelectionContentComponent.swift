import SwiftUI

// MARK: - Onboarding Translation Language Selection Component
struct OnboardingTranslationSelectionContentComponent: View {
    @Binding var selectedLanguage: String?
    let onLanguageSelected: (String) -> Void
    @Binding var showDialog: Bool
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        VStack(spacing: OnboardingConstants.defaultSpacing) {
            ForEach(LanguageOption.availableLanguages) { language in
                TranslationLanguageOptionRow(
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
        .frame(width: OnboardingConstants.getButtonWidth())
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 16)
        .padding(.horizontal, 4)
    }
    
    private func isSameAsAppLanguage(languageName: String) -> Bool {
        let languageCode = getLanguageCode(for: languageName)
        return languageCode == languageManager.currentAppLanguage
    }
    
    private func getLanguageCode(for languageName: String) -> String {
        switch languageName.lowercased() {
        case "deutsch": return "de"
        case "english": return "en"
        case "русский": return "ru"
        case "українська": return "uk"
        default: return "de"
        }
    }
}

private struct TranslationLanguageOptionRow: View {
    let language: LanguageOption
    let isSelected: Bool
    let isDisabled: Bool
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
                .foregroundColor(
                    isDisabled ? Color(.secondaryLabel) :
                    (isSelected ? .white : .primary)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 56)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            isSelected ? selectedFill :
                            (isDisabled ? Color(.systemGray5) : unselectedFill)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .buttonPressAnimation(isPressed: $isPressed)
    }
}


