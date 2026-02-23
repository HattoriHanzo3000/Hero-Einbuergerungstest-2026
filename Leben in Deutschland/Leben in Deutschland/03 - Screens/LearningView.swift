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
    @EnvironmentObject private var premiumManager: PremiumManager
    @Environment(AppRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    @State private var zoomedAsset: ZoomedAsset?
    @State private var showingFeedbackReport = false
    @State private var showingHintSheet = false
    @State private var resetButtonFlash = false
    
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
            
            // Question and answers content
            if !viewModel.questions.isEmpty {
                questionContentView
            }
            
            Divider()
                .background(Color(.separator))
            
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
    
    // MARK: - Header View
    private var headerView: some View {
        QuestionCardHeaderCard(
            onBackTapped: {
                HapticManager.shared.lightImpact()
                if usesRouterNavigation {
                    router.pop()
                } else {
                    dismiss()
                }
            },
            showPremiumButton: true,
            onPremiumTap: { premiumManager.presentPaywall() },
            title: subcategory.name,
            progress: viewModel.questions.count > 1 ? (viewModel.answeredCount, viewModel.questions.count) : nil,
            questionId: viewModel.currentQuestion?.id,
            onReportTapped: { showingFeedbackReport = true },
            trailingActions: {
                HStack(spacing: layoutMetrics.adaptive(8)) {
                    resetButtonWithFlash
                    QuizHeaderIconButton.translation(isActive: viewModel.showTranslation) {
                        HapticManager.shared.lightImpact()
                        viewModel.toggleTranslation()
                    }
                    if let currentQuestion = viewModel.currentQuestion {
                        QuizHeaderIconButton.favorite(isActive: viewModel.isFavorite(questionId: currentQuestion.id)) {
                            HapticManager.shared.lightImpact()
                            viewModel.toggleFavorite(for: currentQuestion.id)
                        }
                    }
                }
            }
        )
    }

    private var resetButtonWithFlash: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            // Trigger flash animation
            withAnimation(.easeOut(duration: 0.3)) {
                resetButtonFlash = true
            }
            // Reset flash after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.2)) {
                    resetButtonFlash = false
                }
            }
            viewModel.resetCurrentQuestion()
        }) {
            ZStack {
                Circle()
                    .fill(.thinMaterial)
                    .frame(width: layoutMetrics.adaptive(38), height: layoutMetrics.adaptive(38))
                
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: layoutMetrics.adaptive(18), weight: .semibold))
                    .foregroundStyle(resetButtonFlash ? Color.green : Color.white)
                    .animation(.easeOut(duration: 0.3), value: resetButtonFlash)
            }
            .frame(width: layoutMetrics.adaptive(38), height: layoutMetrics.adaptive(38))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Reset question")
        .accessibilityAddTraits(.isButton)
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
    }
    
    // MARK: - Footer View
    private var footerView: some View {
        VStack(spacing: layoutMetrics.adaptive(LayoutMetrics.footerSectionSpacing)) {
            HStack(spacing: layoutMetrics.adaptive(12)) {
                // Hint button (appears when answer is shown and hint exists)
                if viewModel.showCorrectAnswer,
                   let currentQuestion = viewModel.currentQuestion,
                   hintService.getHint(for: currentQuestion.id) != nil {
                    HintIconButton(action: hintAction)
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Check/Next button (shrinks when hint appears)
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
                    onPrevious: { viewModel.goToQuestion(at: viewModel.currentIndex - 1) },
                    onNext: { viewModel.goToQuestion(at: viewModel.currentIndex + 1) },
                    onSelectIndex: { viewModel.goToQuestion(at: $0) },
                    arrowCircleSize: layoutMetrics.adaptive(42)
                )
            }
        }
        .padding(.top, layoutMetrics.adaptive(12))
        .background(Color(.systemBackground))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showCorrectAnswer)
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
            suppressGlow: true
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
    
}

// MARK: - Preview

#Preview("Learning – Basic Law") {
    LearningViewPreview.basicLawPreview()
}

#if DEBUG
@MainActor
private enum LearningViewPreview {
    static func basicLawPreview() -> some View {
        let subcategory = loadBasicLawSubcategory()
        populateCorrectAnswers()
        return LearningPreviewHost(subcategory: subcategory)
    }
    
    private static func loadBasicLawSubcategory() -> SubcategoryModel {
        guard
            let url = Bundle.main.url(forResource: "content_en", withExtension: "json", subdirectory: "Content"),
            let data = try? Data(contentsOf: url),
            let contentArray = try? JSONDecoder().decode([ContentData].self, from: data),
            let content = contentArray.first
        else {
            return fallbackSubcategory()
        }
        
        if let match = content.content.first(where: { $0.category == "Law and Constitution" && $0.subcategory == "Basic Law" }) {
            return SubcategoryModel(
                name: match.subcategory,
                categoryName: match.category,
                questions: Array(match.questions.prefix(10))
            )
        }
        
        return fallbackSubcategory()
    }
    
    private static func populateCorrectAnswers() {
        guard
            let url = Bundle.main.url(forResource: "answers", withExtension: "json", subdirectory: "Content"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode([AnswerData].self, from: data)
        else {
            return
        }
        
        ContentService.shared.correctAnswers = Dictionary(uniqueKeysWithValues: decoded.map { ($0.questionId, $0.answerIndex) })
    }
    
    private static func fallbackSubcategory() -> SubcategoryModel {
        let sampleQuestions: [QuestionModel] = [
            QuestionModel(
                id: "Sample-001",
                text: "Which institution is responsible for protecting the Basic Law in Germany?",
                options: [
                    "The Federal Constitutional Court",
                    "The Federal Council",
                    "The Federal Chancellor",
                    "The Bundestag"
                ],
                category: "Law and Constitution",
                subcategory: "Basic Law"
            ),
            QuestionModel(
                id: "Sample-002",
                text: "What is the first article of the German Basic Law about?",
                options: [
                    "Freedom of speech",
                    "Human dignity",
                    "Freedom of assembly",
                    "Right to asylum"
                ],
                category: "Law and Constitution",
                subcategory: "Basic Law"
            )
        ]
        
        return SubcategoryModel(
            name: "Basic Law",
            categoryName: "Law and Constitution",
            questions: sampleQuestions
        )
    }
}
#endif

@MainActor
private struct LearningPreviewHost: View {
    let subcategory: SubcategoryModel
    @State private var router = AppRouter()
    @StateObject private var languageManager = LanguageManager()
    
    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            LearningView(subcategory: subcategory, usesRouterNavigation: false)
                .environment(router)
                .environmentObject(languageManager)
        }
    }
}

