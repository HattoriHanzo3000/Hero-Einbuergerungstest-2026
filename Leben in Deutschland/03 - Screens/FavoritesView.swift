//
//  FavoritesView.swift
//  Leben in Deutschland
//
//  View for displaying favorited questions in a carousel
//

import SwiftUI

// MARK: - Favorites View
struct FavoritesView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    @StateObject private var viewModel = FavoritesViewModel()

    @AppStorage(UserDefaultsKeys.favoritesDisclaimerDismissed) private var disclaimerDismissed = false
    @State private var showDisclaimer = false
    @State private var doNotShowAgain = false
    
    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.hasLoadedOnce {
                loadingView
            } else if viewModel.favoriteQuestions.isEmpty {
                emptyStateView
            } else {
                carouselView
            }
        }
        .id(languageManager.currentAppLanguage)
        .background(Color(.systemBackground))
        .navigationTitle("home_learn_favorites".localized)
        .navigationBarTitleDisplayMode(.inline)
        .hidesLearningChrome()
        .task(id: "\(languageManager.currentAppLanguage)-\(languageManager.currentTranslationLanguage)") {
            viewModel.setLanguageManager(languageManager)
            await viewModel.loadFavorites(
                language: languageManager.currentAppLanguage,
                translationLanguage: languageManager.currentTranslationLanguage
            )
        }
        .onAppear {
            if !disclaimerDismissed {
                showDisclaimer = true
            }
        }
        .sheet(isPresented: $showDisclaimer) {
            LearnModeDisclaimerSheet(
                titleKey: "favorites_disclaimer_title",
                messageKey: "favorites_disclaimer_message",
                accentColor: Color("AppPink"),
                doNotShowAgain: $doNotShowAgain,
                onDismiss: {
                    if doNotShowAgain {
                        disclaimerDismissed = true
                    }
                    showDisclaimer = false
                }
            )
            .environmentObject(languageManager)
            .environment(\.layoutMetrics, layoutMetrics)
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 0) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .accessibilityLabel("Loading favorites")
    }

    // MARK: - Carousel View
    @ViewBuilder
    private var carouselView: some View {
        if viewModel.currentIndex < viewModel.favoriteQuestions.count {
            let question = viewModel.favoriteQuestions[viewModel.currentIndex]
            FavoritesQuestionCard(
                question: question,
                selectedAnswer: nil,
                showCorrectAnswer: true,
                showTranslation: viewModel.showTranslation,
                currentIndex: viewModel.currentIndex + 1,
                totalCount: viewModel.favoriteQuestions.count,
                onAnswerSelected: { _ in },
                onToggleTranslation: { viewModel.toggleTranslation() },
                isTranslationActive: viewModel.showTranslation,
                onToggleFavorite: {
                    if !viewModel.toggleFavorite(for: question.id, isPro: subscriptionManager.effectiveIsPro) {
                        subscriptionManager.presentProLimitSheet(
                            titleKey: "limit_favorites_title",
                            messageKey: "limit_favorites_message",
                            accentColorName: "AppPink"
                        )
                    }
                },
                isFavorite: viewModel.isFavorite(questionId: question.id),
                onGoToQuestion: { viewModel.currentIndex = $0 }
            )
            .environmentObject(languageManager)
            .environmentObject(subscriptionManager)
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 0) {
            
            // Empty state content
            VStack(spacing: layoutMetrics.adaptive(24)) {
                Spacer()
                
                Image(systemName: "heart.slash")
                    .font(.system(size: layoutMetrics.adaptive(64)))
                    .foregroundColor(.secondary)
                    .symbolRenderingMode(.hierarchical)
                
                VStack(spacing: layoutMetrics.adaptive(12)) {
                    Text("favorites_empty_title".localized)
                        .font(.system(.title2, weight: .bold))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Preview
#Preview("Favorites View") {
    FavoritesView()
        .environmentObject(LanguageManager())
        .environmentObject(SubscriptionManager.shared)
        .environment(AppRouter())
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

#Preview("Favorites Empty State") {
    FavoritesView()
        .environmentObject(LanguageManager())
        .environmentObject(SubscriptionManager.shared)
        .environment(AppRouter())
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

