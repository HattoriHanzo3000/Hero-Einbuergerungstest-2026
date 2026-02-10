import SwiftUI

// MARK: - Spaced Repetition View
/// Entry point for the spaced repetition practice session.
struct SpacedRepetitionView: View {
    @Environment(AppRouter.self) private var router
    @EnvironmentObject private var languageManager: LanguageManager
    @StateObject private var viewModel = SpacedRepetitionViewModel()
    
    var body: some View {
        SpacedRepetitionQuestionCard(
            question: viewModel.currentQuestion,
            selectedAnswer: viewModel.selectedAnswer,
            showCorrectAnswer: viewModel.showCorrectAnswer,
            showTranslation: viewModel.showTranslation,
            progress: viewModel.progressState,
            onAnswerSelected: { index in
                viewModel.selectAnswer(index)
            },
            onBackTapped: {
                router.pop()
            },
            onToggleTranslation: {
                viewModel.toggleTranslation()
            },
            isTranslationActive: viewModel.showTranslation,
            onToggleFavorite: {
                viewModel.toggleFavorite(for: viewModel.currentQuestion.id)
            },
            isFavorite: viewModel.isFavorite(questionId: viewModel.currentQuestion.id),
            onCheckTapped: {
                viewModel.handlePrimaryAction()
            },
            isCheckEnabled: viewModel.isPrimaryButtonEnabled,
            testDateMessage: viewModel.testDateMessage,
            recommendedPerDay: viewModel.recommendedPerDay
        )
        .environmentObject(languageManager)
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .hidesTabBar()
        .tabBarHidden(true)
        .task {
            viewModel.refreshSessionIfNeeded()
            if languageManager.currentTranslationLanguage != languageManager.currentAppLanguage {
                await HintService.shared.loadTranslationHints(for: languageManager.currentTranslationLanguage)
            }
        }
    }
}

// MARK: - Preview
#Preview("Spaced Repetition") {
    SpacedRepetitionView()
        .environmentObject(LanguageManager())
        .environment(AppRouter())
}

