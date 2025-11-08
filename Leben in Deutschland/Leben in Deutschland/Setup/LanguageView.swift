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
            
            // Content - Language Sections
            VStack(spacing: 24) {
                // App Language Section
                AppLanguageSection(
                    languages: viewModel.languages,
                    selectedLanguage: languageManager.currentAppLanguage,
                    onLanguageSelected: { code in
                        viewModel.selectAppLanguage(code, languageManager: languageManager)
                    }
                )
                
                // Translation Language Section
                TranslationLanguageSection(
                    languages: viewModel.languages,
                    selectedLanguage: languageManager.currentTranslationLanguage,
                    appLanguage: languageManager.currentAppLanguage,
                    onLanguageSelected: { code in
                        viewModel.selectTranslationLanguage(code, languageManager: languageManager)
                    }
                )
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
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
