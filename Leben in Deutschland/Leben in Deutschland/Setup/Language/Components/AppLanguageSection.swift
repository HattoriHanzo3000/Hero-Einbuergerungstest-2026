//
//  AppLanguageSection.swift
//  Leben in Deutschland
//
//  Application language selection component
//

import SwiftUI

// MARK: - App Language Section
struct AppLanguageSection: View {
    let languages: [LanguageOptionModel]
    let selectedLanguage: String
    let onLanguageSelected: (String) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Section title
            HStack {
                Text("application_title".localized)
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
        LanguageButton(
            language: language,
            isSelected: selectedLanguage == language.code,
            onTap: { onLanguageSelected(language.code) }
        )
    }
}

// MARK: - Language Button Component
private struct LanguageButton: View {
    let language: LanguageOptionModel
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        HStack {
            Text(language.name)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.title2)
                    .accessibilityLabel("Selected")
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.secondary)
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
            isPressed = pressing
        }, perform: {
            onTap()
        })
        .accessibilityLabel(language.name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(isSelected ? "Currently selected language" : "Tap to select this language")
    }
}

// MARK: - Preview
#Preview {
    AppLanguageSection(
        languages: LanguageOptionModel.allLanguages,
        selectedLanguage: "en",
        onLanguageSelected: { _ in }
    )
    .padding()
}

