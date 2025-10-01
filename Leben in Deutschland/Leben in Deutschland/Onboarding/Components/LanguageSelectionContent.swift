import SwiftUI

// MARK: - Language Selection Content
struct LanguageSelectionContent: View {
    @Binding var selectedLanguage: String?
    let onLanguageSelected: (String) -> Void
    @Binding var showDialog: Bool
    
    var body: some View {
        VStack(spacing: OnboardingConstants.defaultSpacing) {
            ForEach(LanguageOption.availableLanguages) { language in
                LanguageOptionRow(
                    language: language,
                    isSelected: selectedLanguage == language.name,
                    onTap: {
                        HapticManager.shared.lightImpact()
                        onLanguageSelected(language.name)
                    }
                )
            }
        }
        .frame(width: OnboardingConstants.getButtonWidth())
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 16)
        .padding(.horizontal, 4)
    }
}

// MARK: - Language Option Row
struct LanguageOptionRow: View {
    let language: LanguageOption
    let isSelected: Bool
    let onTap: () -> Void
    
    private var selectedFill: Color { Color("Fill") }
    private var unselectedFill: Color { Color("Unselected") }
    
    var body: some View {
        Button(action: onTap) {
            Text(language.name)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 15)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? selectedFill : unselectedFill)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
