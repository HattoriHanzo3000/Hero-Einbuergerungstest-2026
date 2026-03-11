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
    
    /// Swipe-down on header dismisses the sheet; gesture is only on the header so body scroll is unaffected.
    private var headerSwipeToDismissGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onEnded { value in
                let dragDown = value.translation.height > 0
                let sufficient = value.translation.height > 80 || value.predictedEndTranslation.height > 120
                if dragDown && sufficient {
                    HapticManager.shared.lightImpact()
                    dismiss()
                }
            }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Stack 1: Header only — swipe down here dismisses the sheet
            headerSection
                .contentShape(Rectangle())
                .gesture(headerSwipeToDismissGesture)

            // Stack 2: Body + footer — scroll lives here only; touches here never dismiss the sheet
            bodySection
        }
        .padding(.top, layoutMetrics.adaptive(16))
        .id(languageManager.currentAppLanguage)
        .background(Color(.systemBackground))
        .fullScreenCover(item: $zoomedAsset) { item in
            FullScreenImageView(assetName: item.name, onDismiss: { zoomedAsset = nil })
        }
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
    
    // MARK: - Header section (separate stack; swipe-down gesture attached here only)
    private var headerSection: some View {
        VStack(spacing: 0) {
            QuestionCardHeaderCard(
                onBackTapped: { dismiss() },
                backIcon: .down,
                gradient: viewModel.isPassed ? .green : .red,
                title: "your_answers".localized,
                titleInBackRow: false,
                questionId: currentQuestion?.originalId,
                onReportTapped: { showingFeedbackReport = true },
                trailingActions: { EmptyView() }
            )
            .padding(.bottom, layoutMetrics.adaptive(12))
            Divider()
                .background(Color(.separator))
        }
    }

    // MARK: - Body section (separate stack; ScrollView + footer — scroll only, no sheet dismiss)
    private var bodySection: some View {
        VStack(spacing: 0) {
            answersContent
            footerView
        }
        .frame(minHeight: 0, maxHeight: .infinity)
    }

    // MARK: - Content (scroll + bottom gradient, same as other question cards)
    private var answersContent: some View {
        ScrollView {
            if let q = currentQuestion {
                let userAnswer = viewModel.answers.first(where: { $0.questionId == q.id })
                let assetName = contentService.getIllustrationAsset(for: q.originalId)
                let questionModel = QuestionModel(
                    id: q.originalId,
                    text: q.text,
                    options: q.options,
                    hint: nil,
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
        .frame(minHeight: 0, maxHeight: .infinity)
        .scrollBounceBehavior(.basedOnSize)
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) {
            LinearGradient(
                colors: [
                    Color(.systemBackground).opacity(0),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: layoutMetrics.adaptive(40))
            .allowsHitTesting(false)
        }
    }

    // MARK: - Footer (action bar + navigation, same as SpacedRepetitionQuestionCard / FavoritesQuestionCard)
    private var footerView: some View {
        VStack(spacing: layoutMetrics.adaptive(LayoutMetrics.footerSectionSpacing)) {
            HStack(spacing: layoutMetrics.adaptive(12)) {
                Spacer(minLength: 0)
                if languageManager.currentTranslationLanguage != "de" {
                    translationFooterButton
                }
                if currentQuestion != nil {
                    favoriteFooterButton
                }
            }
            .padding(.horizontal, layoutMetrics.adaptive(LayoutMetrics.footerHorizontalPadding))

            if viewModel.questions.count > 1 {
                QuestionNavigationBar(
                    questionCount: viewModel.questions.count,
                    currentIndex: currentQuestionIndex,
                    circleColor: circleColor(for:),
                    circleTextColor: { _ in .white },
                    onPrevious: {
                        if currentQuestionIndex > 0 { currentQuestionIndex -= 1 }
                    },
                    onNext: {
                        if currentQuestionIndex < viewModel.questions.count - 1 {
                            currentQuestionIndex += 1
                        }
                    },
                    onSelectIndex: { currentQuestionIndex = $0 },
                    gradient: viewModel.isPassed ? .green : .red,
                    circleGradient: circleGradient(for:),
                    arrowCircleSize: layoutMetrics.adaptive(46),
                    enableScrollHaptic: true,
                    enableChangeHaptic: true
                )
            }
        }
        .padding(.top, layoutMetrics.adaptive(12))
        .background(Color(.systemBackground))
    }

    private func footerIconCircle<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .font(.system(size: layoutMetrics.adaptive(20), weight: .semibold))
            .frame(width: layoutMetrics.adaptive(44), height: layoutMetrics.adaptive(44))
            .background(Circle().fill(Color(.secondarySystemFill)))
    }

    private var translationFooterButton: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            isTranslationActive.toggle()
        }) {
            footerIconCircle {
                Image(systemName: "globe")
                    .foregroundColor(isTranslationActive ? AppActionIconColors.translationActive : Color(.secondaryLabel))
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("spaced_translation_button_accessibility_label".localized)
        .accessibilityAddTraits(.isButton)
    }

    private var favoriteFooterButton: some View {
        Group {
            if let q = currentQuestion {
                let isFavorite = favoritesManager.isFavorite(q.originalId)
                Button(action: {
                    HapticManager.shared.lightImpact()
                    favoritesManager.toggleFavorite(for: q.originalId)
                }) {
                    footerIconCircle {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? AppActionIconColors.favoriteActive : Color(.secondaryLabel))
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("spaced_favorite_button_accessibility_label".localized)
                .accessibilityAddTraits(.isButton)
            }
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

    /// Green gradient for correct, red for wrong, nil for unanswered.
    private func circleGradient(for index: Int) -> LiquidGlassGradient? {
        guard index < viewModel.questions.count else { return nil }
        let question = viewModel.questions[index]
        let userAnswer = viewModel.answers.first(where: { $0.questionId == question.id })
        guard let selectedIndex = userAnswer?.selectedIndex else { return nil }
        let correctIndex = ContentService.shared.correctAnswers[question.originalId]
        return selectedIndex == correctIndex ? .green : .red
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

