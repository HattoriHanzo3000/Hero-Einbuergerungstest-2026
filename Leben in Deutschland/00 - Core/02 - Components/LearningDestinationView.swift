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
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(AppRouter.self) private var router
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
                    Text("Loading questions...".localized)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            } else {
                VStack(spacing: 24) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("learning_load_questions_failed".localizedFormat(subcategoryName))
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    HStack(spacing: 16) {
                        Button("try_again".localized) {
                            Task { await loadSubcategory() }
                        }
                        .buttonStyle(.borderedProminent)
                        Button("back".localized) {
                            router.pop()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
        }
        .task(id: "\(languageManager.currentAppLanguage)-\(languageManager.currentTranslationLanguage)") {
            await loadSubcategory()
            if let sub = subcategory, !sub.questions.isEmpty,
               !TopicAccessPolicy.isFreeCategory(categoryName: categoryName, categories: contentService.categories),
               !subscriptionManager.effectiveIsPro {
                subscriptionManager.presentProLimitSheet(
                    titleKey: "limit_topic_pro_title",
                    messageKey: "limit_topic_pro_message",
                    accentColorName: "AppCaribean"
                )
                subcategory = nil
                router.pop()
            }
        }
    }
    
    private func loadSubcategory() async {
        isLoading = true
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
