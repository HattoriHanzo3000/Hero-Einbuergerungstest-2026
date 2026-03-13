//
//  FavoritesView.swift
//  Leben in Deutschland
//
//  View for displaying favorited questions in a carousel
//

import SwiftUI

// MARK: - Favorites View
struct FavoritesView: View {
    @Environment(AppRouter.self) private var router
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    @StateObject private var viewModel = FavoritesViewModel()

    @AppStorage(UserDefaultsKeys.favoritesDisclaimerDismissed) private var disclaimerDismissed = false
    @State private var showDisclaimer = false
    @State private var doNotShowAgain = false
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.favoriteQuestions.isEmpty {
                emptyStateView
            } else {
                carouselView
            }
        }
        .id(languageManager.currentAppLanguage)
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .hidesTabBar()
        .tabBarHidden(true)
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
                onBackTapped: { router.pop() },
                onToggleTranslation: { viewModel.toggleTranslation() },
                isTranslationActive: viewModel.showTranslation,
                onToggleFavorite: { viewModel.toggleFavorite(for: question.id) },
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
            // Back button header
            HStack {
                AdaptiveIconButton.backButton(action: {
                    router.pop()
                }, tintColor: .primary)
                Spacer()
            }
            .padding(.horizontal, layoutMetrics.adaptive(LayoutMetrics.headerHorizontalPadding))
            .padding(.top, layoutMetrics.adaptive(LayoutMetrics.headerTopPadding))
            
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

