//
//  AllQuestionsView.swift
//  Leben in Deutschland
//
//  Reading mode for all 310 questions (300 General + 10 from selected state).
//  Always free. Design blends Spaced Repetition colors, Learning nav bar, Favorites reading mode.
//

import SwiftUI

// MARK: - All Questions View
struct AllQuestionsView: View {
    @Environment(AppRouter.self) private var router
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var stateManager: StateManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.layoutMetrics) private var layoutMetrics

    @StateObject private var viewModel: AllQuestionsViewModel

    init(stateManager: StateManager) {
        _viewModel = StateObject(wrappedValue: AllQuestionsViewModel(stateManager: stateManager))
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                loadingView
            } else if viewModel.questions.isEmpty {
                emptyStateView
            } else {
                contentView
            }
        }
        .id(languageManager.currentAppLanguage)
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .hidesTabBar()
        .tabBarHidden(true)
        .task(id: "\(languageManager.currentAppLanguage)-\(languageManager.currentTranslationLanguage)-\(stateManager.selectedState ?? "")") {
            await viewModel.loadQuestions(
                language: languageManager.currentAppLanguage,
                translationLanguage: languageManager.currentTranslationLanguage,
                selectedState: stateManager.selectedState
            )
        }
    }

    // MARK: - Content View
    @ViewBuilder
    private var contentView: some View {
        if viewModel.currentIndex < viewModel.questions.count {
            let question = viewModel.questions[viewModel.currentIndex]
            AllQuestionsQuestionCard(
                question: question,
                showTranslation: viewModel.showTranslation,
                currentIndex: viewModel.currentIndex,
                totalCount: viewModel.questions.count,
                onBackTapped: { router.pop() },
                onToggleTranslation: { viewModel.toggleTranslation() },
                isTranslationActive: viewModel.showTranslation,
                onToggleFavorite: { viewModel.toggleFavorite(for: question.id) },
                isFavorite: viewModel.isFavorite(questionId: question.id),
                onGoToQuestion: { viewModel.goToQuestion(at: $0) }
            )
            .environmentObject(languageManager)
            .environmentObject(subscriptionManager)
        }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 0) {
            HStack {
                AdaptiveIconButton.backButton(action: { router.pop() }, tintColor: .primary)
                Spacer()
            }
            .padding(.horizontal, layoutMetrics.adaptive(LayoutMetrics.headerHorizontalPadding))
            .padding(.top, layoutMetrics.adaptive(LayoutMetrics.headerTopPadding))

            VStack(spacing: layoutMetrics.adaptive(24)) {
                Spacer()
                Image(systemName: "book.closed")
                    .font(.system(size: layoutMetrics.adaptive(64)))
                    .foregroundColor(.secondary)
                    .symbolRenderingMode(.hierarchical)

                VStack(spacing: layoutMetrics.adaptive(12)) {
                    Text("all_questions_empty_title".localized)
                        .font(.system(.title2, design: .rounded).weight(.bold).width(.condensed))
                        .foregroundColor(.primary)

                    Text("all_questions_empty_message".localized)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, layoutMetrics.adaptive(32))
                }

                Button("try_again".localized) {
                    Task {
                        await viewModel.loadQuestions(
                            language: languageManager.currentAppLanguage,
                            translationLanguage: languageManager.currentTranslationLanguage,
                            selectedState: stateManager.selectedState
                        )
                    }
                }
                .buttonStyle(.borderedProminent)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Preview
#Preview {
    AllQuestionsView(stateManager: StateManager.shared)
        .environmentObject(LanguageManager())
        .environmentObject(StateManager.shared)
        .environmentObject(SubscriptionManager.shared)
        .environment(AppRouter())
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
