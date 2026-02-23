//
//  TestSessionQuestionCard.swift
//  Leben in Deutschland
//
//  Question card component for test session matching spaced repetition design
//

import SwiftUI

struct TestSessionQuestionCard: View {
    @ObservedObject var viewModel: TestSessionViewModel
    @Binding var showingConfirmation: Bool
    @Binding var showingTimerPopup: Bool
    @Binding var zoomedAsset: ZoomedAsset?
    @State private var showingFeedbackReport = false
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
                QuestionNavigationBar(
                    questionCount: viewModel.questions.count,
                    currentIndex: viewModel.currentQuestionIndex,
                    circleColor: circleColor(for:),
                    circleTextColor: circleTextColor(for:),
                    onPrevious: { viewModel.previousQuestion() },
                    onNext: {
                        if viewModel.currentQuestionIndex < viewModel.questions.count - 1 {
                            viewModel.nextQuestion()
                        }
                    },
                    onSelectIndex: { viewModel.goToQuestion($0) },
                    enableScrollHaptic: true,
                    enableChangeHaptic: true
                )
            }
        }
        .padding(.top, layoutMetrics.adaptive(12))
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
    
    // MARK: - Next/Finish Button (same component and style as LearningView Next button)
    private var nextOrFinishButton: some View {
        let isLastQuestion = viewModel.currentQuestionIndex >= viewModel.questions.count - 1
        let allAnswered = viewModel.allQuestionsAnswered
        let isCurrentQuestionAnswered = viewModel.getAnswerForCurrentQuestion() != nil
        
        let showFinishButton = isLastQuestion || allAnswered
        let nextEnabled = isCurrentQuestionAnswered
        let buttonTitle = showFinishButton ? "finish_test".localized : "next_button".localized
        let nextStyle = QuizActionButton.Style(
            backgroundColor: Color("AppBlueLagoon"),
            disabledBackgroundColor: Color(.systemGray2),
            haloPrimaryColor: Color("AppBlueLagoon").opacity(0.36),
            haloSecondaryColor: Color.white.opacity(0.18),
            suppressGlow: true
        )
        let finishStyle = QuizActionButton.Style(
            backgroundColor: allAnswered ? Color("AppOrange") : Color(.systemGray2),
            disabledBackgroundColor: Color(.systemGray2),
            haloPrimaryColor: Color("AppOrange").opacity(0.36),
            haloSecondaryColor: Color.white.opacity(0.18),
            suppressGlow: true
        )
        
        return QuizActionButton(
            buttonTitle,
            style: showFinishButton ? finishStyle : nextStyle,
            isEnabled: showFinishButton ? true : nextEnabled,
            accessibilityLabel: showFinishButton ? "finish_test".localized : "next_button".localized
        ) {
            if showFinishButton {
                if allAnswered {
                    HapticManager.shared.mediumImpact()
                    onFinish()
                } else {
                    HapticManager.shared.lightImpact()
                    showingIncompleteWarning = true
                }
            } else if nextEnabled {
                HapticManager.shared.mediumImpact()
                viewModel.nextQuestion()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, layoutMetrics.adaptive(24))
    }
    
    // MARK: - Header View
    private var headerView: some View {
        QuestionCardHeaderCard(
            onBackTapped: {
                HapticManager.shared.lightImpact()
                showingConfirmation = true
            },
            showPremiumButton: false,
            gradient: .orange,
            onPremiumTap: nil,
            title: nil,
            progress: (viewModel.answers.count, viewModel.questions.count),
            questionId: viewModel.currentQuestion?.originalId,
            onReportTapped: { showingFeedbackReport = true },
            trailingActions: {
                HStack(spacing: layoutMetrics.adaptive(8)) {
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

                    if let currentQuestion = viewModel.currentQuestion {
                        QuizHeaderIconButton.favorite(isActive: favoritesManager.isFavorite(currentQuestion.originalId)) {
                            HapticManager.shared.lightImpact()
                            favoritesManager.toggleFavorite(for: currentQuestion.originalId)
                        }
                    }
                }
            }
        )
        .padding(.bottom, layoutMetrics.adaptive(12))
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
    
    // MARK: - Helper Functions
    /// Test simulation: answered = App Orange, unanswered = gray. Active circle is larger, not blue.
    private func circleColor(for index: Int) -> Color {
        let isAnswered = viewModel.answers.contains(where: { $0.questionId == viewModel.questions[index].id })
        if isAnswered {
            return Color("AppOrange")
        }
        return Color(.systemGray5)
    }
    
    private func circleTextColor(for index: Int) -> Color {
        let isAnswered = viewModel.answers.contains(where: { $0.questionId == viewModel.questions[index].id })
        if isAnswered {
            return .white
        }
        return .primary
    }
}

