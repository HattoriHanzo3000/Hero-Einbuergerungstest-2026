//
//  LearningDestinationView.swift
//  Leben in Deutschland
//
//  Shared view for loading and displaying LearningView with proper question loading
//

import SwiftUI

// MARK: - Learning Destination View
struct LearningDestinationView: View {
    let subcategoryName: String
    let categoryName: String
    @EnvironmentObject var languageManager: LanguageManager
    @State private var subcategory: SubcategoryModel?
    @State private var isLoading = true
    private let contentService = ContentService.shared
    
    var body: some View {
        Group {
            if let subcategory = subcategory, !subcategory.questions.isEmpty {
                LearningView(subcategory: subcategory)
                    .environmentObject(languageManager)
            } else if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading questions...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Could not load questions for \(subcategoryName)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
        }
        .task {
            await loadSubcategory()
        }
    }
    
    private func loadSubcategory() async {
        // First try to find from already-loaded categories
        subcategory = contentService.findSubcategory(
            named: subcategoryName,
            in: categoryName,
            language: languageManager.currentAppLanguage
        )
        
        // If not found, try loading content
        if subcategory == nil || subcategory?.questions.isEmpty == true {
            await contentService.loadContent(for: languageManager.currentAppLanguage)
            await HintService.shared.loadHints(for: languageManager.currentAppLanguage)
            if languageManager.currentTranslationLanguage != languageManager.currentAppLanguage {
                await HintService.shared.loadTranslationHints(for: languageManager.currentTranslationLanguage)
            }
            subcategory = contentService.findSubcategory(
                named: subcategoryName,
                in: categoryName,
                language: languageManager.currentAppLanguage
            )
        }
        
        isLoading = false
    }
}
