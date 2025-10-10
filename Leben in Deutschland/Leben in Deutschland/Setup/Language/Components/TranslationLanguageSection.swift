//
//  TranslationLanguageSection.swift
//  Leben in Deutschland
//
//  Translation language selection component
//

import SwiftUI

// MARK: - Translation Language Section
struct TranslationLanguageSection: View {
    let languages: [LanguageOptionModel]
    let selectedLanguage: String
    let appLanguage: String
    let onLanguageSelected: (String) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Section title
            HStack {
                Text("settings_translation_language_title".localized)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Language buttons
            ForEach(languages) { language in
                languageButton(for: language)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Language Button
    @ViewBuilder
    private func languageButton(for language: LanguageOptionModel) -> some View {
        TranslationLanguageButton(
            language: language,
            isSelected: selectedLanguage == language.code,
            isDisabled: appLanguage == language.code,
            onTap: { onLanguageSelected(language.code) }
        )
    }
}

// MARK: - Translation Language Button Component
private struct TranslationLanguageButton: View {
    let language: LanguageOptionModel
    let isSelected: Bool
    let isDisabled: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        HStack {
            Text(language.name)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(isDisabled ? Color(.tertiaryLabel) : .primary)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color("Fill"))
                    .font(.title2)
                    .accessibilityLabel("Selected")
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color("Fill"))
                    .font(.title2)
                    .opacity(0)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray5))
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.08), value: isPressed)
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            if !isDisabled {
                isPressed = pressing
            }
        }, perform: {
            if !isDisabled {
                onTap()
            }
        })
        .allowsHitTesting(!isDisabled)
        .accessibilityLabel(language.name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(isDisabled ? "Translation language cannot be the same as app language" : 
                          (isSelected ? "Currently selected translation language" : "Tap to select this translation language"))
    }
}

// MARK: - Preview
#Preview {
    TranslationLanguageSection(
        languages: LanguageOptionModel.allLanguages,
        selectedLanguage: "de",
        appLanguage: "en",
        onLanguageSelected: { _ in }
    )
    .padding()
}

