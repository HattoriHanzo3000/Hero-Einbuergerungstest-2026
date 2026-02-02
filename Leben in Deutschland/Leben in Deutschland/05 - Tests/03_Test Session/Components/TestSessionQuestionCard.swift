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
    
    let onFinish: () -> Void
    let onDismiss: () -> Void
    
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    private let contentService = ContentService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: layoutMetrics.adaptive(20)) {
                headerView
                
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
                            }
                        )
                        .padding(.bottom, layoutMetrics.adaptive(80))
                    }
                }
            }
            
            Spacer()
            
            // Bottom buttons
            VStack(spacing: layoutMetrics.adaptive(12)) {
                // Back and Next buttons
                HStack(spacing: 16) {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        viewModel.previousQuestion()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Text("back".localized)
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(viewModel.canGoPrevious() ? Color.accentColor : .gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                    }
                    .disabled(!viewModel.canGoPrevious())
                    
                    Spacer()
                    
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        if viewModel.currentQuestionIndex < viewModel.questions.count - 1 {
                            viewModel.nextQuestion()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text("next".localized)
                                .font(.headline)
                                .fontWeight(.semibold)
                            Image(systemName: "chevron.right")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(viewModel.currentQuestionIndex < viewModel.questions.count - 1 ? Color.accentColor : .gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                    }
                    .disabled(viewModel.currentQuestionIndex == viewModel.questions.count - 1)
                }
                .padding(.horizontal, layoutMetrics.adaptive(24))
                
                if viewModel.allQuestionsAnswered {
                    QuizActionButton(
                        "finish_test".localizedUppercased(),
                        style: finishButtonStyle
                    ) {
                        HapticManager.shared.mediumImpact()
                        onFinish()
                    }
                    .padding(.horizontal, layoutMetrics.adaptive(24))
                }
                
                // Question navigation bar
                if viewModel.questions.count > 1 {
                    questionNavigationBar
                }
            }
            .padding(.top, layoutMetrics.adaptive(12))
            .padding(.bottom, layoutMetrics.adaptive(24))
            .background(Color(.systemBackground))
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
        VStack(alignment: .leading, spacing: layoutMetrics.adaptive(16)) {
            // Back button
            HStack {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    showingConfirmation = true
                }) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: layoutMetrics.adaptive(20), weight: .semibold))
                        .foregroundColor(Color(.systemGray6))
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
            
            // Progress bar
            ProgressView(
                value: Double(viewModel.answers.count),
                total: max(Double(viewModel.questions.count), 1)
            )
            .progressViewStyle(
                LinearProgressViewStyle(tint: Color(.systemGray6))
            )
            .frame(height: layoutMetrics.adaptive(8))
            .clipShape(Capsule())
            
            // Question ID + Actions
            HStack {
                if let currentQuestion = viewModel.currentQuestion {
                    HStack(spacing: 8) {
                        Text("question_label".localized + " \(currentQuestion.originalId)")
                            .font(.system(.headline).weight(.semibold))
                            .foregroundColor(Color(.systemGray6))
                        
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
                
                Spacer()
                
                // Timer button
                if showingTimerPopup {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingTimerPopup.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "gauge.with.needle.fill")
                                .font(.system(size: layoutMetrics.adaptive(14), weight: .bold))
                                .foregroundColor(viewModel.remainingTime < 300 ? .red : Color(.systemGray6))
                                .rotationEffect(.degrees(Double(viewModel.timerTick * 6)))
                            Text(timeString(from: viewModel.remainingTime))
                                .font(.system(size: layoutMetrics.adaptive(14), weight: .semibold, design: .monospaced))
                                .foregroundColor(viewModel.remainingTime < 300 ? .red : Color(.systemGray6))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.18))
                        .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                } else {
                    QuizHeaderIconButton(
                        systemName: "gauge.with.needle.fill",
                        isActive: viewModel.remainingTime < 300,
                        activeTint: viewModel.remainingTime < 300 ? .red : .orange,
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
                        activeTint: .pink,
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
        .padding(.vertical, layoutMetrics.adaptive(18))
        .padding(.horizontal, layoutMetrics.adaptive(20))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(liquidGlassBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: layoutMetrics.adaptive(32),
                style: .continuous
            )
        )
        .overlay(
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
        )
        .padding(.horizontal)
        .padding(.top, layoutMetrics.adaptive(8))
    }
    
    var liquidGlassBackground: some View {
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
    
    private var finishButtonStyle: QuizActionButton.Style {
        QuizActionButton.Style(
            backgroundColor: Color("AppBlueLagoon"),
            disabledBackgroundColor: Color(.systemGray2),
            haloPrimaryColor: Color("AppBlueLagoon").opacity(0.36),
            haloSecondaryColor: Color.white.opacity(0.18),
            showsHaloWhenDisabled: false
        )
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Question Navigation Bar
    private var questionNavigationBar: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<viewModel.questions.count, id: \.self) { index in
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            viewModel.goToQuestion(index)
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
                .padding(.horizontal, layoutMetrics.adaptive(20))
            }
            .frame(height: 44)
            .onChange(of: viewModel.currentQuestionIndex) { _, newIndex in
                withAnimation {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func circleColor(for index: Int) -> Color {
        if index == viewModel.currentQuestionIndex {
            return Color("SelectedCircle")
        } else if viewModel.answers.contains(where: { $0.questionId == viewModel.questions[index].id }) {
            // Answered question - show as answered but not correct/wrong
            return Color("SelectedCircle").opacity(0.5)
        } else {
            return Color(.systemGray5)
        }
    }
    
    private func circleTextColor(for index: Int) -> Color {
        if index == viewModel.currentQuestionIndex {
            return Color(.systemGray6)
        } else if viewModel.answers.contains(where: { $0.questionId == viewModel.questions[index].id }) {
            return Color(.systemGray6)
        } else {
            return .primary
        }
    }
}

