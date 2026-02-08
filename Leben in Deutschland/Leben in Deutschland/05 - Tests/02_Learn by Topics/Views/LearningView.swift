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
    // Press states removed to avoid gesture conflicts with Button taps
    
    @State private var zoomedAsset: ZoomedAsset?
    @State private var showingFeedbackReport = false
    @State private var showingHintSheet = false
    @State private var resetButtonFlash = false
    
    private let hintService = HintService.shared
    
    struct ZoomedAsset: Identifiable {
        let id = UUID()
        let name: String
    }
    
    struct FullScreenImageView: View {
        let assetName: String
        let onDismiss: () -> Void
        
        var body: some View {
            ZStack {
                // Dark background
                Color.black
                    .ignoresSafeArea()
                    .onTapGesture {
                        HapticManager.shared.lightImpact()
                        onDismiss()
                    }
                
                // Close button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            onDismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.9))
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .padding(.top, 16)
                        .padding(.trailing, 16)
                    }
                    Spacer()
                }
                
                // Zoomable image
                ZoomableImage(imageName: assetName)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 60)
            }
            .transition(.opacity)
        }
    }
    
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
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
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
        .task {
            // Ensure hints are loaded for current and translation language
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
        headerContent
            .padding(.vertical, layoutMetrics.adaptive(18))
            .padding(.horizontal, layoutMetrics.adaptive(20))
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(liquidGlassBackground)
            .clipShape(headerRoundedRectangle)
            .overlay(headerBorderOverlay)
            .padding(.horizontal)
            .padding(.top, layoutMetrics.adaptive(8))
    }
    
    private var headerContent: some View {
        VStack(alignment: .leading, spacing: layoutMetrics.adaptive(16)) {
            backButtonView
            
            // Subcategory title
            Text(subcategory.name)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
            
            // Progress bar
            ProgressView(value: Double(viewModel.answeredCount), total: Double(viewModel.questions.count))
                .progressViewStyle(LinearProgressViewStyle(tint: Color(.systemGray6)))
                .frame(height: layoutMetrics.adaptive(8))
                .clipShape(Capsule())
            
            // Question ID + Actions
            questionHeaderRow
        }
    }
    
    private var backButtonView: some View {
        HStack {
            Button(action: {
                HapticManager.shared.lightImpact()
                if usesRouterNavigation {
                    router.pop()
                } else {
                    dismiss()
                }
            }) {
                Image(systemName: "chevron.backward")
                    .font(.system(size: layoutMetrics.adaptive(20), weight: .semibold))
                    .foregroundColor(.white)
                    .padding(layoutMetrics.adaptive(10))
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.18))
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("back_button_accessibility_label".localized)
            
            Spacer()
            
            PremiumCrownButton(action: { premiumManager.presentPaywall() }, color: .white)
        }
    }
    
    private var questionHeaderRow: some View {
        HStack {
            questionLabelView
            Spacer()
            headerActionButtons
        }
    }
    
    private var questionLabelView: some View {
        HStack(spacing: 8) {
            if let currentQuestion = viewModel.currentQuestion {
                Text("question_label".localized + " \(currentQuestion.id)")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.white)
                    .accessibilityLabel("question_label".localized + " " + currentQuestion.id)
                
                Button(action: {
                    HapticManager.shared.lightImpact()
                    showingFeedbackReport = true
                }) {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.accentColor)
                }
            }
        }
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
    
    private var headerActionButtons: some View {
        HStack(spacing: layoutMetrics.adaptive(8)) {
            // Reset button with green flash
            resetButtonWithFlash
            
            // Translation button
            QuizHeaderIconButton(
                systemName: "globe",
                isActive: viewModel.showTranslation,
                activeTint: Color("AppOrange"),
                inactiveTint: .white,
                showGlow: false,
                showStroke: false,
                accessibilityLabel: "spaced_translation_button_accessibility_label".localized,
                accessibilityHint: nil,
                action: {
                    HapticManager.shared.lightImpact()
                    viewModel.toggleTranslation()
                }
            )
            
            // Favorite button
            if let currentQuestion = viewModel.currentQuestion {
                QuizHeaderIconButton(
                    systemName: "heart",
                    isActive: viewModel.isFavorite(questionId: currentQuestion.id),
                    activeTint: Color("AppPink"),
                    inactiveTint: .white,
                    showGlow: false,
                    showStroke: false,
                    useFilledWhenActive: true,
                    accessibilityLabel: "spaced_favorite_button_accessibility_label".localized,
                    accessibilityHint: nil,
                    action: {
                        HapticManager.shared.lightImpact()
                        viewModel.toggleFavorite(for: currentQuestion.id)
                    }
                )
            }
        }
    }
    
    private var headerRoundedRectangle: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: layoutMetrics.adaptive(32),
            style: .continuous
        )
    }
    
    private var headerBorderOverlay: some View {
        RoundedRectangle(
            cornerRadius: layoutMetrics.adaptive(32),
            style: .continuous
        )
        .stroke(
            LinearGradient(
                colors: [
                    .white.opacity(0.4),
                    .white.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: 0.8
        )
    }
    
    private var liquidGlassBackground: some View {
        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(32), style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color("AppBlueLagoon").opacity(0.9),
                        Color("AppBlueLagoon").opacity(0.65),
                        Color("AppCaribean").opacity(0.45)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.20),
                        Color.white.opacity(0.05),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(38), style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.45),
                                Color.white.opacity(0.12)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.6
                    )
            )
            .background(
                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(38), style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
    }
    
    // MARK: - Action Buttons
    private var actionButtonsView: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let sidePadding = screenWidth * 0.05
            
            HStack(spacing: 10) {
                // Question ID
                if let currentQuestion = viewModel.currentQuestion {
                    Text("question_label".localized + " \(currentQuestion.id)")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(.systemGray6))
                        .padding(.leading, sidePadding)
                }
                
                Spacer()
                
                // Reset button
                ActionIconButton.reset {
                    viewModel.resetCurrentQuestion()
                }
                
                // Translate button
                ActionIconButton.translation(isActive: viewModel.showTranslation) {
                    viewModel.toggleTranslation()
                }
                
                // Favorite button
                if let currentQuestion = viewModel.currentQuestion {
                    ActionIconButton.favorite(isActive: viewModel.isFavorite(questionId: currentQuestion.id)) {
                        viewModel.toggleFavorite(for: currentQuestion.id)
                    }
                    .padding(.trailing, sidePadding)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(height: layoutMetrics.adaptive(64))
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
        VStack(spacing: layoutMetrics.adaptive(8)) {
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
            .padding(.horizontal, layoutMetrics.adaptive(24))
            
            // Question navigation bar
            if viewModel.questions.count > 1 {
                questionNavigationBar
            }
        }
        .padding(.top, layoutMetrics.adaptive(12))
        .padding(.bottom, layoutMetrics.adaptive(24))
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
        HapticManager.shared.lightImpact()
        showingHintSheet = true
    }
    
    // MARK: - Question Navigation Bar
    private var questionNavigationBar: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<viewModel.questions.count, id: \.self) { index in
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            viewModel.goToQuestion(at: index)
                        }) {
                            Circle()
                                .fill(circleColor(for: index))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text("\(index + 1)")
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                        .foregroundColor(circleTextColor(for: index))
                                )
                        }
                        .id(index)
                    }
                }
                .padding(.horizontal, layoutMetrics.adaptive(24))
            }
            .frame(height: 44)
            .padding(.bottom, layoutMetrics.adaptive(16))
            .onChange(of: viewModel.currentIndex) { _, newIndex in
                withAnimation {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func circleColor(for index: Int) -> Color {
        if index == viewModel.currentIndex {
            return Color("SelectedCircle")
        } else if viewModel.isCorrect(at: index) {
            return Color("CorrectCircle")
        } else if viewModel.isIncorrect(at: index) {
            return Color("WrongCircle")
        } else {
            return Color(.systemGray5)
        }
    }
    
    private func circleTextColor(for index: Int) -> Color {
        if index == viewModel.currentIndex {
            return Color(.systemGray6)
        } else if viewModel.isCorrect(at: index) || viewModel.isIncorrect(at: index) {
            return Color(.systemGray6)
        } else {
            return .primary
        }
    }
}

// MARK: - Hint Icon Button
private struct HintIconButton: View {
    let action: () -> Void
    @Environment(\.layoutMetrics) private var layoutMetrics
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            action()
        }) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: layoutMetrics.adaptive(20), weight: .semibold))
                .foregroundColor(.white)
                .padding(.vertical, layoutMetrics.adaptive(18))
                .frame(width: layoutMetrics.adaptive(80))
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(28), style: .continuous)
                            .fill(.ultraThinMaterial)
                        
                        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(28), style: .continuous)
                            .fill(Color("AppOrange"))
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(28), style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
                )
                .shadow(
                    color: Color.black.opacity(0.16),
                    radius: layoutMetrics.adaptive(22),
                    y: layoutMetrics.adaptive(10)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("hint_button_title".localized)
        .accessibilityAddTraits(.isButton)
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

