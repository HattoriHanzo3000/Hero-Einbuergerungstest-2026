//
//  TestSessionQuestionCard.swift
//  Leben in Deutschland
//
//  Question card component for test session matching spaced repetition design
//

import SwiftUI

struct TestSessionQuestionCard: View {
    struct ZoomedAsset: Identifiable {
        let id = UUID()
        let name: String
    }
    
    @ObservedObject var viewModel: TestSessionViewModel
    @Binding var showingConfirmation: Bool
    @Binding var showingTimerPopup: Bool
    @Binding var zoomedAsset: ZoomedAsset?
    @State private var showingFeedbackReport = false
    @State private var lastHorizontalScrollHapticTs: Double = 0
    @State private var showingIncompleteWarning = false
    
    let onFinish: () -> Void
    let onDismiss: () -> Void
    
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    private let contentService = ContentService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.bottom, layoutMetrics.adaptive(12))
            
            Divider()
                .background(Color(.separator))
            
            // Question and answers content
            if viewModel.currentQuestion != nil {
                questionContentView
            }
            
            Divider()
                .background(Color(.separator))
            
            // Bottom buttons
            footerView
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .bottom)
        .fullScreenCover(item: $zoomedAsset) { item in
            FullScreenImageView(assetName: item.name, onDismiss: {
                zoomedAsset = nil
            })
        }
        .sheet(isPresented: $showingFeedbackReport) {
            if let currentQuestion = viewModel.currentQuestion {
                FeedbackReportView(
                    questionId: currentQuestion.originalId,
                    questionText: currentQuestion.text,
                    category: currentQuestion.category
                )
                .environmentObject(languageManager)
            }
        }
    }
    
    // MARK: - Question Content
    private var questionContentView: some View {
        ScrollView {
            if let currentQuestion = viewModel.currentQuestion {
                let questionModel = QuestionModel(
                    id: currentQuestion.originalId,
                    text: currentQuestion.text,
                    options: currentQuestion.options,
                    category: currentQuestion.category,
                    subcategory: nil
                )
                
                // Get illustration asset - ensure ContentService.shared is used directly
                let assetName = ContentService.shared.getIllustrationAsset(for: currentQuestion.originalId)
                
                QuestionCard(
                    question: questionModel,
                    selectedAnswer: viewModel.getAnswerForCurrentQuestion()?.selectedIndex,
                    showCorrectAnswer: false,
                    showTranslation: false,
                    onAnswerSelected: { index in
                        HapticManager.shared.lightImpact()
                        viewModel.answerQuestion(selectedIndex: index)
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
        VStack(spacing: layoutMetrics.adaptive(12)) {
            // Next/Finish button above navigation circles
            nextOrFinishButton
            
            // Same nav row as TestAnswersView/LearningView: back + circles (under separators) + forward. Answered = AppBlueLagoon.
            if viewModel.questions.count > 1 {
                questionNavigationBar
            }
        }
        .padding(.top, layoutMetrics.adaptive(12))
        .padding(.bottom, layoutMetrics.adaptive(32))
        .background(Color(.systemBackground))
        .alert(
            "answer_all_questions_title".localized,
            isPresented: $showingIncompleteWarning,
            actions: {
                Button("ok_button".localized, role: .cancel) {
                    HapticManager.shared.lightImpact()
                }
            },
            message: {
                Text("answer_all_questions_message".localized)
            }
        )
    }
    
    // MARK: - Next/Finish Button
    private var nextOrFinishButton: some View {
        let isLastQuestion = viewModel.currentQuestionIndex >= viewModel.questions.count - 1
        let allAnswered = viewModel.allQuestionsAnswered
        let isCurrentQuestionAnswered = viewModel.getAnswerForCurrentQuestion() != nil
        
        // Label: "Finish Test" when on last question OR all answered; else "Next"
        let showFinishButton = isLastQuestion || allAnswered
        let nextEnabled = isCurrentQuestionAnswered
        // Finish Test is active only when all answered; Next is active when current answered
        let isButtonActive = showFinishButton ? allAnswered : nextEnabled
        let buttonText = showFinishButton ? "finish_test".localizedUppercased() : "next_button".localizedUppercased()
        let activeColor: Color = showFinishButton ? Color("AppOrange") : Color("AppBlueLagoon")
        
        return Button(action: {
            if showFinishButton {
                if allAnswered {
                    HapticManager.shared.mediumImpact()
                    onFinish()
                } else {
                    // Gray Finish Test on last question: show warning
                    HapticManager.shared.lightImpact()
                    showingIncompleteWarning = true
                }
            } else {
                // Next: only act when active; gray tap does nothing
                if nextEnabled {
                    HapticManager.shared.mediumImpact()
                    viewModel.nextQuestion()
                }
            }
        }) {
            Text(buttonText)
                .font(.system(.headline, design: .rounded).weight(.bold))
                .foregroundColor(.white)
                .padding(.vertical, layoutMetrics.adaptive(18))
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(28), style: .continuous)
                            .fill(.ultraThinMaterial)
                        
                        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(28), style: .continuous)
                            .fill(isButtonActive ? activeColor : Color(.systemGray2))
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(28), style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
                    .shadow(
                        color: Color.black.opacity(isButtonActive ? 0.16 : 0.08),
                        radius: layoutMetrics.adaptive(22),
                        y: layoutMetrics.adaptive(10)
                    )
                )
                .opacity(isButtonActive ? 1 : 0.75)
                .scaleEffect(isButtonActive ? 1 : 0.98)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(showFinishButton ? "finish_test".localized : "next_button".localized)
        .accessibilityAddTraits(.isButton)
        .padding(.horizontal, layoutMetrics.adaptive(24))
    }
    
    // MARK: - Full Screen Image View
    private struct FullScreenImageView: View {
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
            
            // Progress bar
            ProgressView(
                value: Double(viewModel.answers.count),
                total: max(Double(viewModel.questions.count), 1)
            )
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
                showingConfirmation = true
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
                Text("question_label".localized + " \(currentQuestion.originalId)")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.white)
                    .accessibilityLabel("question_label".localized + " " + currentQuestion.originalId)
                
                Button(action: {
                    HapticManager.shared.lightImpact()
                    showingFeedbackReport = true
                }) {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private var headerActionButtons: some View {
        HStack(spacing: layoutMetrics.adaptive(8)) {
            // Timer button
            if showingTimerPopup {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showingTimerPopup.toggle()
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(19), style: .continuous)
                            .fill(.thinMaterial)
                            .frame(width: layoutMetrics.adaptive(80), height: layoutMetrics.adaptive(38))
                        
                        HStack(spacing: 4) {
                            Image(systemName: "gauge.with.needle.fill")
                                .font(.system(size: layoutMetrics.adaptive(18), weight: .semibold))
                                .foregroundColor(viewModel.remainingTime < 300 ? .red : .white)
                                .rotationEffect(.degrees(Double(viewModel.timerTick * 6)))
                            Text(timeString(from: viewModel.remainingTime))
                                .font(.system(size: layoutMetrics.adaptive(14), weight: .semibold, design: .monospaced))
                                .foregroundColor(viewModel.remainingTime < 300 ? .red : .white)
                        }
                    }
                    .frame(height: layoutMetrics.adaptive(38))
                }
                .buttonStyle(.plain)
            } else {
                QuizHeaderIconButton(
                    systemName: "gauge.with.needle.fill",
                    isActive: viewModel.remainingTime < 300,
                    activeTint: viewModel.remainingTime < 300 ? .red : .orange,
                    inactiveTint: .white,
                    showGlow: false,
                    showStroke: false,
                    accessibilityLabel: "Timer",
                    accessibilityHint: nil,
                    action: {
                        HapticManager.shared.lightImpact()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingTimerPopup.toggle()
                        }
                    }
                )
            }
            
            // Favorite button
            if let currentQuestion = viewModel.currentQuestion {
                QuizHeaderIconButton(
                    systemName: "heart",
                    isActive: favoritesManager.isFavorite(currentQuestion.originalId),
                    activeTint: Color("AppPink"),
                    inactiveTint: .white,
                    showGlow: false,
                    showStroke: false,
                    useFilledWhenActive: true,
                    accessibilityLabel: "spaced_favorite_button_accessibility_label".localized,
                    accessibilityHint: nil,
                    action: {
                        HapticManager.shared.lightImpact()
                        favoritesManager.toggleFavorite(for: currentQuestion.originalId)
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
    
    /// Test simulation: header gradient from App Orange to App Red.
    var liquidGlassBackground: some View {
        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(32), style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color("AppOrange").opacity(0.95),
                        Color("AppOrange").opacity(0.75),
                        Color(red: 0.77, green: 0.21, blue: 0.12).opacity(0.85) // App red (matches premium/paywall)
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
    
    private var finishButtonStyle: QuizActionButton.Style {
        QuizActionButton.Style(
            backgroundColor: Color("AppOrange"),
            disabledBackgroundColor: Color(.systemGray2),
            haloPrimaryColor: Color("AppOrange").opacity(0.36),
            haloSecondaryColor: Color.white.opacity(0.18),
            showsHaloWhenDisabled: false,
            suppressGlow: true
        )
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Question Navigation Bar (same design as TestAnswersView/LearningView)
    private var questionNavigationBar: some View {
        let navigationCircleSize = layoutMetrics.adaptive(34)
        return ScrollViewReader { proxy in
            HStack(spacing: layoutMetrics.adaptive(12)) {
                // Back arrow
                Button(action: {
                    HapticManager.shared.lightImpact()
                    viewModel.previousQuestion()
                }) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: layoutMetrics.adaptive(16), weight: .semibold))
                        .foregroundColor(viewModel.currentQuestionIndex > 0 ? .white : Color.white.opacity(0.5))
                        .frame(width: navigationCircleSize, height: navigationCircleSize)
                        .background(Circle().fill(Color("AppBlueLagoon")))
                }
                .disabled(viewModel.currentQuestionIndex <= 0)
                .buttonStyle(.plain)
                .accessibilityLabel("Previous question")
                .accessibilityHint("Go to previous question")
                
                // Scrollable circles under vertical separators
                ZStack(alignment: .center) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<viewModel.questions.count, id: \.self) { index in
                                Button(action: {
                                    HapticManager.shared.lightImpact()
                                    viewModel.goToQuestion(index)
                                }) {
                                    Circle()
                                        .fill(circleColor(for: index))
                                        .frame(width: navigationCircleSize, height: navigationCircleSize)
                                        .overlay(
                                            Text("\(index + 1)")
                                                .font(.system(size: layoutMetrics.adaptive(14), weight: .semibold))
                                                .foregroundColor(circleTextColor(for: index))
                                        )
                                }
                                .id(index)
                            }
                        }
                        .padding(.horizontal, 0)
                    }
                    .onChange(of: viewModel.currentQuestionIndex) { _, newIndex in
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
                    
                    HStack {
                        navigationBarVerticalSeparator(size: navigationCircleSize)
                        Spacer(minLength: 0)
                        navigationBarVerticalSeparator(size: navigationCircleSize)
                    }
                    .frame(height: navigationCircleSize)
                    .allowsHitTesting(false)
                }
                .frame(maxWidth: .infinity)
                
                // Forward arrow
                Button(action: {
                    HapticManager.shared.lightImpact()
                    if viewModel.currentQuestionIndex < viewModel.questions.count - 1 {
                        viewModel.nextQuestion()
                    }
                }) {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: layoutMetrics.adaptive(16), weight: .semibold))
                        .foregroundColor(viewModel.currentQuestionIndex < viewModel.questions.count - 1 ? .white : Color.white.opacity(0.5))
                        .frame(width: navigationCircleSize, height: navigationCircleSize)
                        .background(Circle().fill(Color("AppBlueLagoon")))
                }
                .disabled(viewModel.currentQuestionIndex >= viewModel.questions.count - 1)
                .buttonStyle(.plain)
                .accessibilityLabel("Next question")
                .accessibilityHint("Go to next question")
            }
            .padding(.horizontal, layoutMetrics.adaptive(24))
            .frame(height: navigationCircleSize + layoutMetrics.adaptive(8))
            .padding(.bottom, layoutMetrics.adaptive(16))
        }
    }
    
    private func navigationBarVerticalSeparator(size: CGFloat) -> some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(width: 1)
            .frame(height: size)
    }
    
    // MARK: - Helper Functions
    /// Test simulation: current = App Blue, answered (not current) = App Orange, unanswered = gray.
    private func circleColor(for index: Int) -> Color {
        let isAnswered = viewModel.answers.contains(where: { $0.questionId == viewModel.questions[index].id })
        if index == viewModel.currentQuestionIndex {
            return Color("AppBlueLagoon")
        }
        if isAnswered {
            return Color("AppOrange")
        }
        return Color(.systemGray5)
    }
    
    private func circleTextColor(for index: Int) -> Color {
        let isAnswered = viewModel.answers.contains(where: { $0.questionId == viewModel.questions[index].id })
        if index == viewModel.currentQuestionIndex || isAnswered {
            return .white
        }
        return .primary
    }
}

