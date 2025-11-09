//
//  LanguageView.swift
//  Leben in Deutschland
//
//  Main coordinator view for language selection
//

import SwiftUI

// MARK: - Language View
struct LanguageView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = LanguageViewModel()
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Header
            SetupHeader(title: "language_title", onDismiss: {
                dismiss()
            })
            
            Spacer(minLength: MainScreenConstants.adaptiveValue(16))
                .frame(height: MainScreenConstants.adaptiveValue(16))
                .clipped()
            
            ScrollView {
                VStack(spacing: MainScreenConstants.adaptiveValue(20)) {
                    AppLanguageSection(
                        languages: viewModel.languages,
                        selectedLanguage: languageManager.currentAppLanguage,
                        onLanguageSelected: { code in
                            viewModel.selectAppLanguage(code, languageManager: languageManager)
                        }
                    )
                    
                    TranslationLanguageSection(
                        languages: viewModel.languages,
                        selectedLanguage: languageManager.currentTranslationLanguage,
                        appLanguage: languageManager.currentAppLanguage,
                        onLanguageSelected: { code in
                            viewModel.selectTranslationLanguage(code, languageManager: languageManager)
                        }
                    )
                }
                .padding(.horizontal, MainScreenConstants.adaptiveValue(24))
                .padding(.top, MainScreenConstants.adaptiveValue(8))
                .padding(.bottom, MainScreenConstants.adaptiveValue(24))
            }
            
            // Temporary Ad Placeholder (matches main screen)
            VStack {
                Text("Ad Placeholder")
                    .font(.system(.caption, design: .rounded).weight(.medium))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: MainScreenConstants.adaptiveValue(60))
            .padding(.horizontal, MainScreenConstants.adaptiveValue(16))
            .padding(.bottom, MainScreenConstants.adaptiveValue(16))
            .background(
                RoundedRectangle(cornerRadius: MainScreenConstants.adaptiveValue(16))
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [6, 3]))
                    .foregroundColor(Color.green.opacity(0.7))
            )
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview
#Preview {
    LanguageView()
        .environmentObject(LanguageManager())
}

#Preview("Medium") {
    LanguageView()
        .environmentObject(LanguageManager())
        .environment(\.dynamicTypeSize, .medium)
}

#Preview("xxxLarge") {
    LanguageView()
        .environmentObject(LanguageManager())
        .environment(\.dynamicTypeSize, .xxxLarge)
}
