//
//  SearchQuestionDetailView.swift
//  Leben in Deutschland
//
//  Read-only question detail opened from search. Uses ReviewQuestionCard.
//

import SwiftUI

// MARK: - Search Question Detail View
struct SearchQuestionDetailView: View {
    let question: QuestionModel

    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    @State private var showTranslation = false
    @ObservedObject private var favoritesManager = FavoritesManager.shared

    var body: some View {
        ReviewQuestionCard(
            question: question,
            selectedAnswer: nil,
            showCorrectAnswer: true,
            showTranslation: showTranslation,
            currentIndex: 1,
            totalCount: 1,
            onAnswerSelected: { _ in },
            onToggleTranslation: { showTranslation.toggle() },
            isTranslationActive: showTranslation,
            onToggleFavorite: {
                if !favoritesManager.toggleFavorite(for: question.id, isPro: subscriptionManager.effectiveIsPro) {
                    subscriptionManager.presentProLimitSheet(
                        titleKey: "limit_favorites_title",
                        messageKey: "limit_favorites_message",
                        accentColorName: "AppPink"
                    )
                }
            },
            isFavorite: favoritesManager.isFavorite(question.id),
            onGoToQuestion: nil,
            footerBottomExtraPadding: layoutMetrics.adaptive(16),
            showsHeaderProgress: false
        )
        .environmentObject(languageManager)
        .environmentObject(subscriptionManager)
        .id(languageManager.currentAppLanguage)
        .background(Color(.systemBackground))
        .navigationTitle("tab_search_title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .tabBar)
        .hidesBottomBarWhenPushed(false)
        .task(id: "\(languageManager.currentAppLanguage)-\(languageManager.currentTranslationLanguage)") {
            await HintService.shared.loadHints(for: languageManager.currentAppLanguage)
            if languageManager.currentTranslationLanguage != languageManager.currentAppLanguage {
                await HintService.shared.loadTranslationHints(for: languageManager.currentTranslationLanguage)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SearchQuestionDetailView(
            question: QuestionModel(
                id: "001",
                text: "What is the capital of Germany?",
                options: ["Berlin", "Munich", "Hamburg", "Frankfurt"],
                hint: nil,
                category: "Geography",
                subcategory: "Cities"
            )
        )
    }
    .environmentObject(LanguageManager())
    .environmentObject(SubscriptionManager.shared)
}
