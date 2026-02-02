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
    @EnvironmentObject private var premiumManager: PremiumManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var showPremiumAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.favoriteQuestions.isEmpty {
                emptyStateView
            } else {
                carouselView
            }
        }
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if !premiumManager.isPremium {
                showPremiumAlert = true
            }
        }
        .alert("premium_favorites_alert_title".localized, isPresented: $showPremiumAlert) {
            Button("premium_favorites_alert_cancel".localized, role: .cancel) {
                router.pop()
            }
            Button("premium_favorites_alert_upgrade".localized) {
                router.pop()
                // Navigate to premium after a short delay to allow pop animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    router.push(.premium)
                }
            }
        } message: {
            Text("premium_favorites_alert_message".localized)
        }
        .task {
            if premiumManager.isPremium {
                viewModel.setLanguageManager(languageManager)
                await viewModel.loadFavorites(language: languageManager.currentAppLanguage)
            }
        }
    }
    
    // MARK: - Carousel View
    private var carouselView: some View {
        TabView(selection: $viewModel.currentIndex) {
            ForEach(Array(viewModel.favoriteQuestions.enumerated()), id: \.element.id) { index, question in
                FavoritesQuestionCard(
                    question: question,
                    selectedAnswer: viewModel.selectedAnswers[question.id],
                    showCorrectAnswer: viewModel.showCorrectAnswers[question.id] ?? false,
                    showTranslation: viewModel.showTranslation,
                    currentIndex: index + 1,
                    totalCount: viewModel.favoriteQuestions.count,
                    onAnswerSelected: { answerIndex in
                        viewModel.selectAnswer(answerIndex, for: question.id)
                    },
                    onBackTapped: {
                        router.pop()
                    },
                    onToggleTranslation: {
                        viewModel.toggleTranslation()
                    },
                    isTranslationActive: viewModel.showTranslation,
                    onToggleFavorite: {
                        viewModel.toggleFavorite(for: question.id)
                    },
                    isFavorite: viewModel.isFavorite(questionId: question.id),
                    onCheckTapped: {
                        if viewModel.showCorrectAnswers[question.id] ?? false {
                            // Move to next question if answer is already shown
                            if viewModel.currentIndex < viewModel.favoriteQuestions.count - 1 {
                                viewModel.currentIndex += 1
                            }
                        } else {
                            viewModel.checkAnswer(for: question.id)
                        }
                    },
                    isCheckEnabled: (viewModel.selectedAnswers[question.id] != nil && !(viewModel.showCorrectAnswers[question.id] ?? false)) || (viewModel.showCorrectAnswers[question.id] ?? false)
                )
                .environmentObject(languageManager)
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 0) {
            // Back button header
            HStack {
                AdaptiveIconButton.backButton {
                    router.pop()
                }
                Spacer()
            }
            .padding(.horizontal, layoutMetrics.adaptive(20))
            .padding(.top, layoutMetrics.adaptive(8))
            
            // Empty state content
            VStack(spacing: layoutMetrics.adaptive(24)) {
                Spacer()
                
                Image(systemName: "heart.slash")
                    .font(.system(size: layoutMetrics.adaptive(64)))
                    .foregroundColor(.secondary)
                    .symbolRenderingMode(.hierarchical)
                
                VStack(spacing: layoutMetrics.adaptive(12)) {
                    Text("favorites_empty_title".localized)
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundColor(.primary)
                    
                    Text("favorites_empty_message".localized)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, layoutMetrics.adaptive(32))
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
        .environmentObject(PremiumManager.shared)
        .environment(AppRouter())
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

#Preview("Favorites Empty State") {
    FavoritesView()
        .environmentObject(LanguageManager())
        .environmentObject(PremiumManager.shared)
        .environment(AppRouter())
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

