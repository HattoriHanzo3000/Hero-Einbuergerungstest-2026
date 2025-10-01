import SwiftUI

// MARK: - Translation Language Selection Content
struct TranslationLanguageSelectionContent: View {
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
        .frame(width: OnboardingConstants.getButtonWidth())
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 16)
        .padding(.horizontal, 4)
    }
    
    // MARK: - Helper Methods
    
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

// MARK: - Translation Language Option Row
struct TranslationLanguageOptionRow: View {
    let language: LanguageOption
    let isSelected: Bool
    let isDisabled: Bool
    let onTap: () -> Void
    
    private var selectedFill: Color { Color("Fill") }
    private var unselectedFill: Color { Color("Unselected") }
    
    var body: some View {
        Button(action: onTap) {
            Text(language.name)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(
                    isDisabled ? Color(.secondaryLabel) : 
                    (isSelected ? .white : .primary)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 15)
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
    }
}
