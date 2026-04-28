import SwiftUI

// MARK: - Spaced Repetition View
/// Entry point for the spaced repetition practice session.
struct SpacedRepetitionView: View {
    @Environment(AppRouter.self) private var router
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    @StateObject private var viewModel = SpacedRepetitionViewModel()

    @AppStorage(UserDefaultsKeys.spacedRepetitionDisclaimerDismissed) private var disclaimerDismissed = false
    @State private var showDisclaimer = false
    @State private var doNotShowAgain = false

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
                if !viewModel.toggleFavorite(for: viewModel.currentQuestion.id, isPro: subscriptionManager.effectiveIsPro) {
                    subscriptionManager.presentProLimitSheet(
                        titleKey: "limit_favorites_title",
                        messageKey: "limit_favorites_message",
                        accentColorName: "AppPink"
                    )
                }
            },
            isFavorite: viewModel.isFavorite(questionId: viewModel.currentQuestion.id),
            onCheckTapped: {
                if !viewModel.handlePrimaryAction(isPro: subscriptionManager.effectiveIsPro) {
                    subscriptionManager.presentProLimitSheet(
                        titleKey: "limit_smart_learning_title",
                        messageKey: "limit_smart_learning_message",
                        accentColorName: "AppBlueLagoon"
                    )
                }
            },
            isCheckEnabled: viewModel.isPrimaryButtonEnabled
        )
        .environmentObject(languageManager)
        .id(languageManager.currentAppLanguage)
        .background(Color(.systemBackground))
        .hidesLearningChrome()
        .task(id: "\(languageManager.currentAppLanguage)-\(languageManager.currentTranslationLanguage)") {
            // Ensure content and hints are loaded when app or translation language changes
            await ContentService.shared.loadContent(for: languageManager.currentAppLanguage)
            await HintService.shared.loadHints(for: languageManager.currentAppLanguage)
            viewModel.refreshSessionIfNeeded()
            if languageManager.currentTranslationLanguage != languageManager.currentAppLanguage {
                await HintService.shared.loadTranslationHints(for: languageManager.currentTranslationLanguage)
            }
        }
        .onAppear {
            if !disclaimerDismissed {
                showDisclaimer = true
            }
        }
        .overlay {
            if let stage = viewModel.pendingEagleLevelUp {
                EagleLevelUpView(
                    stage: stage,
                    readinessPercentage: viewModel.progressState.answeredCount,
                    onDismiss: { withAnimation(.easeInOut(duration: 0.25)) { viewModel.pendingEagleLevelUp = nil } }
                )
                .environmentObject(languageManager)
                .environment(\.layoutMetrics, layoutMetrics)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .zIndex(1000)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.pendingEagleLevelUp != nil)
        .sheet(isPresented: $showDisclaimer) {
            LearnModeDisclaimerSheet(
                titleKey: "sr_disclaimer_title",
                messageKey: "sr_disclaimer_message",
                accentColor: Color("AppBlueLagoon"),
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
}

// MARK: - Preview
#Preview("Spaced Repetition") {
    SpacedRepetitionView()
        .environmentObject(LanguageManager())
        .environmentObject(SubscriptionManager.shared)
        .environment(AppRouter())
}

