//
//  TestAnswersView.swift
//  Leben in Deutschland
//
//  View for reviewing all test answers with correct/incorrect highlights
//

import SwiftUI

struct TestAnswersView: View {
    @ObservedObject var viewModel: TestSessionViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var favoritesManager: FavoritesManager
    
    @State private var currentQuestionIndex: Int = 0
    @State private var showingFeedbackReport = false
    @State private var isTranslationActive = false
    
    private let contentService = ContentService.shared
    @State private var zoomedAsset: ZoomedAsset?
    
    private var currentQuestion: TestQuestion? {
        guard currentQuestionIndex < viewModel.questions.count else { return nil }
        return viewModel.questions[currentQuestionIndex]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.bottom, layoutMetrics.adaptive(12))
            Divider()
                .background(Color(.separator))
            answersContent
            Divider()
                .background(Color(.separator))
            navigationBar
        }
        .id(languageManager.currentAppLanguage)
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .hidesTabBar()
        .tabBarHidden(true)
        .sheet(isPresented: $showingFeedbackReport) {
            if let q = currentQuestion {
                FeedbackReportView(
                    questionId: q.originalId,
                    questionText: q.text,
                    category: q.category
                )
                .environmentObject(languageManager)
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        QuestionCardHeaderCard(
            onBackTapped: { dismiss() },
            backIcon: .down,
            showPremiumButton: false,
            gradient: .orange,
            onPremiumTap: nil,
            title: "your_answers".localized,
            progress: nil,
            questionId: currentQuestion?.originalId,
            onReportTapped: { showingFeedbackReport = true },
            trailingActions: {
                HStack(spacing: layoutMetrics.adaptive(8)) {
                    if languageManager.currentTranslationLanguage != "de" {
                        QuizHeaderIconButton.translation(isActive: isTranslationActive) {
                            HapticManager.shared.lightImpact()
                            isTranslationActive.toggle()
                        }
                    }
                    if let q = currentQuestion {
                        QuizHeaderIconButton.favorite(isActive: favoritesManager.isFavorite(q.originalId)) {
                            HapticManager.shared.lightImpact()
                            favoritesManager.toggleFavorite(for: q.originalId)
                        }
                    }
                }
            }
        )
    }
    
    // MARK: - Content (matches LearningView: single ScrollView, QuestionCard owns full content)
    private var answersContent: some View {
        ScrollView {
            if let q = currentQuestion {
                let userAnswer = viewModel.answers.first(where: { $0.questionId == q.id })
                let assetName = contentService.getIllustrationAsset(for: q.originalId)
                let questionModel = QuestionModel(
                    id: q.originalId,
                    text: q.text,
                    options: q.options,
                    category: q.category,
                    subcategory: nil
                )
                QuestionCard(
                    question: questionModel,
                    selectedAnswer: userAnswer?.selectedIndex,
                    showCorrectAnswer: true,
                    showTranslation: isTranslationActive,
                    onAnswerSelected: { _ in },
                    illustrationAssetName: assetName,
                    onImageTapped: {
                        guard let assetName = assetName else { return }
                        HapticManager.shared.lightImpact()
                        zoomedAsset = ZoomedAsset(name: assetName)
                    },
                    suppressAnswerGlow: true
                )
                .padding(.bottom, layoutMetrics.adaptive(16))
            }
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Navigation (matching LearningView style; circles slide under vertical separators)
    private var navigationBar: some View {
        VStack(spacing: 0) {
            QuestionNavigationBar(
                questionCount: viewModel.questions.count,
                currentIndex: currentQuestionIndex,
                circleColor: circleColor(for:),
                onPrevious: {
                    if currentQuestionIndex > 0 {
                        currentQuestionIndex -= 1
                    }
                },
                onNext: {
                    if currentQuestionIndex < viewModel.questions.count - 1 {
                        currentQuestionIndex += 1
                    }
                },
                onSelectIndex: { currentQuestionIndex = $0 },
                arrowCircleSize: layoutMetrics.adaptive(42),
                enableScrollHaptic: true,
                enableChangeHaptic: true
            )
            .padding(.top, layoutMetrics.adaptive(12))
        }
        .background(Color(.systemBackground))
        .fullScreenCover(item: $zoomedAsset) { item in
            FullScreenImageView(assetName: item.name, onDismiss: { zoomedAsset = nil })
        }
    }
    
    // MARK: - Helpers
    private func circleColor(for index: Int) -> Color {
        guard index < viewModel.questions.count else { return Color(.systemGray5) }
        let question = viewModel.questions[index]
        let userAnswer = viewModel.answers.first(where: { $0.questionId == question.id })
        if let selectedIndex = userAnswer?.selectedIndex {
            let correctIndex = ContentService.shared.correctAnswers[question.originalId]
            if selectedIndex == correctIndex {
                return Color("CorrectCircle")
            } else {
                return Color("WrongCircle")
            }
        }
        return Color(.systemGray5)
    }
}

// MARK: - Preview
private func makePreviewAnswersViewModel() -> TestSessionViewModel {
    let sampleQuestions: [TestQuestion] = (0..<3).map { i in
        TestQuestion(
            id: i,
            originalId: "\(100 + i)",
            text: "Sample question \(i + 1) text?",
            options: ["Option A", "Option B", "Option C", "Option D"],
            correctIndex: 0,
            isRegional: false,
            category: "Politics"
        )
    }
    let vm = TestSessionViewModel()
    vm.initializeTest(generalQuestions: sampleQuestions, regionalQuestions: [])
    for i in 0..<vm.questions.count {
        vm.goToQuestion(i)
        let q = vm.questions[i]
        vm.answerQuestion(selectedIndex: i == 0 ? (q.correctIndex + 1) % max(1, q.options.count) : q.correctIndex)
    }
    vm.finishTest()
    return vm
}

#Preview("Test Answers") {
    TestAnswersView(viewModel: makePreviewAnswersViewModel())
        .environmentObject(LanguageManager())
        .environmentObject(FavoritesManager.shared)
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

