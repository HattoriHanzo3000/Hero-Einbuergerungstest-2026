//
//  LearningView.swift
//  Leben in Deutschland
//
//  Learning mode view for studying questions by topic
//

import SwiftUI

// MARK: - Learning View
struct LearningView: View {
    let subcategory: SubcategoryModel
    private let usesRouterNavigation: Bool
    
    @StateObject private var viewModel: LearningViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(AppRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    @State private var zoomedAsset: ZoomedAsset?
    @State private var showingFeedbackReport = false
    @State private var showingHintSheet = false
    @State private var resetButtonFlash = false
    @State private var hintGlowPhase = false
    
    private let hintService = HintService.shared
    
    init(subcategory: SubcategoryModel, usesRouterNavigation: Bool = true) {
        self.subcategory = subcategory
        self.usesRouterNavigation = usesRouterNavigation
        self._viewModel = StateObject(wrappedValue: LearningViewModel(subcategory: subcategory))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title, progress, and actions
            headerView
                .padding(.bottom, layoutMetrics.adaptive(12))

            Divider()
                .background(Color(.separator))

            // Question and answers content (fades into footer, no separator)
            if !viewModel.questions.isEmpty {
                questionContentView
            }

            // Footer with navigation and check button
            footerView
        }
        .id(languageManager.currentAppLanguage)
        .background(Color(.systemBackground).ignoresSafeArea(edges: .bottom))
        .toolbar(.hidden, for: .navigationBar)
        .hidesTabBar()
        .tabBarHidden(true)
        .fullScreenCover(item: $zoomedAsset) { item in
            FullScreenImageView(assetName: item.name, onDismiss: {
                zoomedAsset = nil
            })
        }
        .sheet(isPresented: $showingFeedbackReport) {
            if let currentQuestion = viewModel.currentQuestion {
                FeedbackReportView(
                    questionId: currentQuestion.id,
                    questionText: currentQuestion.text,
                    category: currentQuestion.category
                )
                .environmentObject(languageManager)
            }
        }
        .sheet(isPresented: $showingHintSheet) {
            if let currentQuestion = viewModel.currentQuestion {
                if let hint = hintService.getHint(for: currentQuestion.id) {
                    HintSheetView(
                        hint: hint,
                        translatedHint: viewModel.showTranslation && languageManager.currentTranslationLanguage != languageManager.currentAppLanguage
                            ? hintService.getTranslationHint(for: currentQuestion.id)
                            : nil
                    )
                } else {
                    HintSheetView(hint: "no_hint_available".localized)
                }
            }
        }
        .task(id: "\(languageManager.currentAppLanguage)-\(languageManager.currentTranslationLanguage)") {
            // Ensure hints are loaded when app or translation language changes
            await HintService.shared.loadHints(for: languageManager.currentAppLanguage)
            if languageManager.currentTranslationLanguage != languageManager.currentAppLanguage {
                await HintService.shared.loadTranslationHints(for: languageManager.currentTranslationLanguage)
            }
        }
        .onAppear {
            viewModel.loadInitialState()
        }
    }

    private func footerIconCircle<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .font(.system(size: layoutMetrics.adaptive(20), weight: .semibold))
            .frame(width: layoutMetrics.adaptive(44), height: layoutMetrics.adaptive(44))
            .background(Circle().fill(Color(.secondarySystemFill)))
    }

    private var hintFooterButton: some View {
        let bulbColor = hintGlowPhase ? Color("AppAmber") : Color(.secondaryLabel)
        return Button(action: {
            HapticManager.shared.lightImpact()
            hintAction()
        }) {
            footerIconCircle {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(bulbColor)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: hintGlowPhase)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("hint_button_title".localized)
        .accessibilityAddTraits(.isButton)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                hintGlowPhase = true
            }
        }
    }

    private var resetFooterButton: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            withAnimation(.easeOut(duration: 0.3)) { resetButtonFlash = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.2)) { resetButtonFlash = false }
            }
            viewModel.resetCurrentQuestion()
        }) {
            footerIconCircle {
                Image(systemName: "arrow.counterclockwise")
                    .foregroundColor(resetButtonFlash ? Color.green : Color(.secondaryLabel))
                    .animation(.easeOut(duration: 0.3), value: resetButtonFlash)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Reset question")
        .accessibilityAddTraits(.isButton)
    }

    private var translationFooterButton: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            viewModel.toggleTranslation()
        }) {
            footerIconCircle {
                Image(systemName: "globe")
                    .foregroundColor(viewModel.showTranslation ? AppActionIconColors.translationActive : Color(.secondaryLabel))
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("spaced_translation_button_accessibility_label".localized)
        .accessibilityAddTraits(.isButton)
    }

    private var favoriteFooterButton: some View {
        Group {
            if let currentQuestion = viewModel.currentQuestion {
                let isFavorite = viewModel.isFavorite(questionId: currentQuestion.id)
                Button(action: {
                    HapticManager.shared.lightImpact()
                    viewModel.toggleFavorite(for: currentQuestion.id)
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

    // MARK: - Header View
    private var headerView: some View {
        QuestionCardHeaderCard(
            onBackTapped: {
                if usesRouterNavigation {
                    router.pop()
                } else {
                    dismiss()
                }
            },
            title: subcategory.name,
            progress: viewModel.questions.count > 1 ? (viewModel.answeredCount, viewModel.questions.count) : nil,
            questionId: viewModel.currentQuestion?.id,
            onReportTapped: { showingFeedbackReport = true },
            showPremiumButton: true,
            onPremiumTap: { subscriptionManager.presentPaywall() },
            trailingActions: { EmptyView() }
        )
    }
    
    // MARK: - Question Content
    private var questionContentView: some View {
        ScrollView {
            if let question = viewModel.currentQuestion {
                let assetName = ContentService.shared.getIllustrationAsset(for: question.id)
                QuestionCard(
                    question: question,
                    selectedAnswer: viewModel.selectedAnswer,
                    showCorrectAnswer: viewModel.showCorrectAnswer,
                    showTranslation: viewModel.showTranslation,
                    onAnswerSelected: { index in
                        viewModel.selectAnswer(index)
                    },
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
        .overlay(alignment: .bottom) {
            // Dissolve effect: content fades as it scrolls under the footer (iOS Photos-style)
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
    
    // MARK: - Footer View
    private var footerView: some View {
        VStack(spacing: layoutMetrics.adaptive(LayoutMetrics.footerSectionSpacing)) {
            // Action bar: hint (left, appears with animation after answer), reset, translation, favorite (right)
            if viewModel.currentQuestion != nil {
                HStack(spacing: layoutMetrics.adaptive(12)) {
                    if viewModel.showCorrectAnswer,
                       let currentQuestion = viewModel.currentQuestion,
                       hintService.getHint(for: currentQuestion.id) != nil {
                        hintFooterButton
                            .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    }
                    Spacer(minLength: 0)
                    resetFooterButton
                    translationFooterButton
                    favoriteFooterButton
                }
                .padding(.horizontal, layoutMetrics.adaptive(LayoutMetrics.footerHorizontalPadding))
            }

            HStack(spacing: layoutMetrics.adaptive(12)) {
                // Check/Next button
                QuizActionButton(
                    buttonTitle,
                    style: checkButtonStyle,
                    isEnabled: viewModel.canCheck || viewModel.showCorrectAnswer,
                    accessibilityLabel: checkButtonAccessibilityLabel
                ) {
                    HapticManager.shared.lightImpact()
                    if viewModel.showCorrectAnswer {
                        viewModel.nextQuestion()
                    } else {
                        viewModel.checkAnswer()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, layoutMetrics.adaptive(LayoutMetrics.footerHorizontalPadding))
            
            // Question navigation bar
            if viewModel.questions.count > 1 {
                QuestionNavigationBar(
                    questionCount: viewModel.questions.count,
                    currentIndex: viewModel.currentIndex,
                    circleColor: circleColor(for:),
                    circleTextColor: { _ in .white },
                    onPrevious: { viewModel.goToQuestion(at: viewModel.currentIndex - 1) },
                    onNext: { viewModel.goToQuestion(at: viewModel.currentIndex + 1) },
                    onSelectIndex: { viewModel.goToQuestion(at: $0) },
                    gradient: .blue,
                    circleGradient: circleGradient(for:),
                    arrowCircleSize: layoutMetrics.adaptive(46),
                    enableScrollHaptic: true,
                    enableChangeHaptic: false
                )
            }
        }
        .padding(.top, layoutMetrics.adaptive(12))
        .background(Color(.systemBackground))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showCorrectAnswer)
        .onChange(of: viewModel.showCorrectAnswer) { _, isRevealed in
            if !isRevealed { hintGlowPhase = false }
        }
    }
    
    private var buttonTitle: String {
        viewModel.showCorrectAnswer ? "next_button".localized : "check_answer_button".localized
    }
    
    private var checkButtonAccessibilityLabel: String {
        if viewModel.showCorrectAnswer {
            return "next_button".localized
        } else {
            return "check_answer_button_accessibility_label".localized
        }
    }
    
    private var checkButtonStyle: QuizActionButton.Style {
        QuizActionButton.Style(
            backgroundColor: Color("AppBlueLagoon"),
            disabledBackgroundColor: Color(.systemGray2),
            haloPrimaryColor: Color("AppBlueLagoon").opacity(0.36),
            haloSecondaryColor: Color.white.opacity(0.18),
            showsHaloWhenDisabled: viewModel.showCorrectAnswer,
            suppressGlow: true,
            gradient: .blue
        )
    }
    
    private func hintAction() {
        showingHintSheet = true
    }
    
    // MARK: - Helper Functions
    private func circleColor(for index: Int) -> Color {
        if viewModel.isCorrect(at: index) {
            return Color("CorrectCircle")
        } else if viewModel.isIncorrect(at: index) {
            return Color("WrongCircle")
        } else {
            return Color(.systemGray5)
        }
    }

    /// Green gradient for correct, red for wrong, nil for unanswered (uses circleColor).
    private func circleGradient(for index: Int) -> LiquidGlassGradient? {
        if viewModel.isCorrect(at: index) { return .green }
        if viewModel.isIncorrect(at: index) { return .red }
        return nil
    }
    
}
