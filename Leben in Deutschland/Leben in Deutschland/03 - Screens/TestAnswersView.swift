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
    @State private var lastHorizontalScrollHapticTs: Double = 0.0
    @State private var showingFeedbackReport = false
    @State private var isTranslationActive = false
    
    private let contentService = ContentService.shared
    
    private struct ZoomedAsset: Identifiable {
        let id = UUID()
        let name: String
    }
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
        .fontDesign(.rounded)
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
            onBackTapped: {
                HapticManager.shared.lightImpact()
                dismiss()
            },
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
                        QuizHeaderIconButton(
                            systemName: "globe",
                            isActive: isTranslationActive,
                            activeTint: Color("AppOrange"),
                            inactiveTint: .white,
                            showGlow: false,
                            showStroke: false,
                            accessibilityLabel: "spaced_translation_button_accessibility_label".localized,
                            accessibilityHint: nil,
                            action: {
                                HapticManager.shared.lightImpact()
                                isTranslationActive.toggle()
                            }
                        )
                    }
                    if let q = currentQuestion {
                        QuizHeaderIconButton(
                            systemName: "heart",
                            isActive: favoritesManager.isFavorite(q.originalId),
                            activeTint: Color("AppPink"),
                            inactiveTint: .white,
                            showGlow: false,
                            showStroke: false,
                            useFilledWhenActive: true,
                            accessibilityLabel: "spaced_favorite_button_accessibility_label".localized,
                            accessibilityHint: nil,
                            action: {
                                HapticManager.shared.lightImpact()
                                favoritesManager.toggleFavorite(for: q.originalId)
                            }
                        )
                    }
                }
            }
        )
        .padding(.bottom, layoutMetrics.adaptive(12))
    }
    
    // MARK: - Content
    private var answersContent: some View {
        ScrollView {
            VStack(spacing: layoutMetrics.adaptive(20)) {
                if let q = currentQuestion {
                    answerContent(for: q)
                }
            }
        }
    }
    
    @ViewBuilder
    private func answerContent(for q: TestQuestion) -> some View {
        let userAnswer = viewModel.answers.first(where: { $0.questionId == q.id })
        let assetName = contentService.getIllustrationAsset(for: q.originalId)
        
        // Question illustration
        if let assetName = assetName {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 280)
                .padding(.horizontal, layoutMetrics.adaptive(22))
                .padding(.top, layoutMetrics.adaptive(8))
                .onTapGesture {
                    HapticManager.shared.lightImpact()
                    zoomedAsset = ZoomedAsset(name: assetName)
                }
        }
        
        // Convert TestQuestion to QuestionModel for QuestionCard
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
            showCorrectAnswer: true, // Show correct/incorrect answers in review
            showTranslation: isTranslationActive, // Show translation when globe button is active
            onAnswerSelected: { _ in }, // Answers are read-only in review
            suppressAnswerGlow: true // Remove glow effect from answers
        )
        .padding(.bottom, layoutMetrics.adaptive(80))
    }
    
    // MARK: - Navigation (matching LearningView style; circles slide under vertical separators)
    private var navigationBar: some View {
        let navigationCircleSize = layoutMetrics.adaptive(34) // One step smaller than LearningView (38)
        return VStack(spacing: 0) {
            ScrollViewReader { proxy in
                HStack(spacing: layoutMetrics.adaptive(12)) {
                    // Previous question arrow
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        if currentQuestionIndex > 0 {
                            currentQuestionIndex -= 1
                        }
                    }) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: layoutMetrics.adaptive(16), weight: .semibold))
                            .foregroundColor(currentQuestionIndex > 0 ? .white : Color.white.opacity(0.5))
                            .frame(width: navigationCircleSize, height: navigationCircleSize)
                            .background(Circle().fill(Color("AppBlueLagoon")))
                    }
                    .disabled(currentQuestionIndex == 0)
                    .buttonStyle(.plain)
                    .accessibilityLabel("Previous question")
                    .accessibilityHint("Go to previous question")
                    
                    // Circles scroll under vertical separators
                    ZStack(alignment: .center) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<viewModel.questions.count, id: \.self) { index in
                                    Button(action: {
                                        HapticManager.shared.lightImpact()
                                        currentQuestionIndex = index
                                    }) {
                                        Circle()
                                            .fill(circleColor(for: index))
                                            .frame(width: navigationCircleSize, height: navigationCircleSize)
                                            .overlay(
                                                Text("\(index + 1)")
                                                    .font(.system(size: layoutMetrics.adaptive(14), weight: .semibold))
                                                    .foregroundColor(.white)
                                            )
                                    }
                                    .id(index)
                                }
                            }
                            .padding(.horizontal, 0)
                        }
                        .onChange(of: currentQuestionIndex) { _, newIndex in
                            withAnimation {
                                proxy.scrollTo(newIndex, anchor: .center)
                            }
                            HapticManager.shared.lightImpact()
                        }
                        .simultaneousGesture(DragGesture().onChanged { _ in
                            let now = Date().timeIntervalSince1970
                            if now - lastHorizontalScrollHapticTs > 0.2 {
                                lastHorizontalScrollHapticTs = now
                                HapticManager.shared.lightImpact()
                            }
                        })
                        
                        // Vertical separators overlaid so circles slide underneath
                        HStack {
                            navigationBarVerticalSeparator
                            Spacer(minLength: 0)
                            navigationBarVerticalSeparator
                        }
                        .frame(height: navigationCircleSize)
                        .allowsHitTesting(false)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Forward arrow
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        if currentQuestionIndex < viewModel.questions.count - 1 {
                            currentQuestionIndex += 1
                        }
                    }) {
                        Image(systemName: "chevron.forward")
                            .font(.system(size: layoutMetrics.adaptive(16), weight: .semibold))
                            .foregroundColor(currentQuestionIndex < viewModel.questions.count - 1 ? .white : Color.white.opacity(0.5))
                            .frame(width: navigationCircleSize, height: navigationCircleSize)
                            .background(Circle().fill(Color("AppBlueLagoon")))
                    }
                    .disabled(currentQuestionIndex >= viewModel.questions.count - 1)
                    .buttonStyle(.plain)
                    .accessibilityLabel("Next question")
                    .accessibilityHint("Go to next question")
                }
                .padding(.horizontal, layoutMetrics.adaptive(24))
                .frame(height: navigationCircleSize + layoutMetrics.adaptive(8))
                .padding(.top, layoutMetrics.adaptive(12)) // Same as space between check button and separator in spaced repetition
                .padding(.bottom, layoutMetrics.adaptive(16))
            }
        }
        .background(Color(.systemBackground))
        .fullScreenCover(item: $zoomedAsset) { item in
            ZStack {
                Color.black.opacity(0.8).ignoresSafeArea()
                    .onTapGesture { zoomedAsset = nil }
                ZoomableImage(imageName: item.name)
                    .padding(24)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    /// Vertical separator in navigation row (system separator color).
    private var navigationBarVerticalSeparator: some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(width: 1)
            .frame(height: layoutMetrics.adaptive(34))
    }
    
    // MARK: - Helpers
    private func circleColor(for index: Int) -> Color {
        if index == currentQuestionIndex {
            return Color("AppBlueLagoon")
        } else {
            // Check if this question was answered correctly or incorrectly
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

