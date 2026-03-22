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
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    private let contentService = ContentService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.bottom, layoutMetrics.adaptive(12))

            Divider()
                .background(Color(.separator))

            if viewModel.currentQuestion != nil {
                questionScrollView
            }
            footerView
        }
        .background(Color(.systemBackground).ignoresSafeArea(edges: .bottom))
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
    
    // MARK: - Question Content (scroll + bottom gradient dissolve)
    private var questionScrollView: some View {
        ScrollView {
            if let currentQuestion = viewModel.currentQuestion {
                let questionModel = QuestionModel(
                    id: currentQuestion.originalId,
                    text: currentQuestion.text,
                    options: currentQuestion.options,
                    hint: nil,
                    category: currentQuestion.category,
                    subcategory: nil
                )
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

    // MARK: - Footer View
    private var footerView: some View {
        VStack(spacing: layoutMetrics.adaptive(LayoutMetrics.footerSectionSpacing)) {
            // Action bar: favorite only (timer is in header)
            HStack(spacing: layoutMetrics.adaptive(12)) {
                Spacer(minLength: 0)
                favoriteFooterButton
            }
            .padding(.horizontal, layoutMetrics.adaptive(LayoutMetrics.footerHorizontalPadding))

            nextOrFinishButton

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
                    gradient: .orange,
                    arrowCircleSize: layoutMetrics.adaptive(46),
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
        let buttonTitle = (showFinishButton ? "finish_test" : "next_button").localizedUppercased()
        let nextStyle = QuizActionButton.Style(
            backgroundColor: Color("AppBlueLagoon"),
            disabledBackgroundColor: Color(.systemGray2),
            haloPrimaryColor: Color("AppBlueLagoon").opacity(0.36),
            haloSecondaryColor: Color.white.opacity(0.18),
            suppressGlow: true,
            gradient: .orange
        )
        let finishStyle = QuizActionButton.Style(
            backgroundColor: allAnswered ? Color("AppOrange") : Color(.systemGray2),
            disabledBackgroundColor: Color(.systemGray2),
            haloPrimaryColor: Color("AppOrange").opacity(0.36),
            haloSecondaryColor: Color.white.opacity(0.18),
            suppressGlow: true,
            gradient: .orange
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
        .padding(.horizontal, layoutMetrics.adaptive(LayoutMetrics.footerHorizontalPadding))
    }
    
    private func footerIconCircle<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .font(.system(size: layoutMetrics.adaptive(20), weight: .semibold))
            .frame(width: layoutMetrics.adaptive(44), height: layoutMetrics.adaptive(44))
            .background(Circle().fill(Color(.secondarySystemFill)))
    }

    private var favoriteFooterButton: some View {
        Group {
            if let currentQuestion = viewModel.currentQuestion {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    if !favoritesManager.toggleFavorite(for: currentQuestion.originalId, isPremium: subscriptionManager.effectiveIsPremium) {
                        subscriptionManager.presentPremiumLimitSheet(
                            titleKey: "limit_favorites_title",
                            messageKey: "limit_favorites_message",
                            accentColorName: "AppPink"
                        )
                    }
                }) {
                    footerIconCircle {
                        Image(systemName: favoritesManager.isFavorite(currentQuestion.originalId) ? "heart.fill" : "heart")
                            .foregroundColor(favoritesManager.isFavorite(currentQuestion.originalId) ? AppActionIconColors.favoriteActive : Color(.secondaryLabel))
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
            onBackTapped: { showingConfirmation = true },
            gradient: .orange,
            title: "test_simulation_title".localized,
            titleInBackRow: false,
            progress: (viewModel.answers.count, viewModel.questions.count),
            questionId: viewModel.currentQuestion?.originalId,
            onReportTapped: { showingFeedbackReport = true },
            trailingActions: { headerTimerButton }
        )
    }
    
    /// Expandable timer in header row (same row as back arrow): icon only when collapsed, icon + time when expanded, inside a rounded rectangle.
    private var headerTimerButton: some View {
        let isLowTime = viewModel.remainingTime < 300
        let timerColor: Color = isLowTime ? .red : .white
        return Button(action: {
            HapticManager.shared.lightImpact()
            withAnimation(.easeInOut(duration: 0.2)) {
                showingTimerPopup.toggle()
            }
        }) {
            HStack(spacing: layoutMetrics.adaptive(2)) {
                Image(systemName: "gauge.with.needle.fill")
                    .font(.system(size: layoutMetrics.adaptive(22), weight: .semibold, design: .rounded))
                    .foregroundColor(timerColor)
                    .rotationEffect(.degrees(showingTimerPopup ? Double(viewModel.timerTick * 6) : 0))
                if showingTimerPopup {
                    Text(timeString(from: viewModel.remainingTime))
                        .font(
                            .system(size: layoutMetrics.adaptive(26), weight: .semibold)
                                .width(.expanded)
                        )
                        .monospacedDigit()
                        .foregroundColor(timerColor)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
            .padding(.horizontal, layoutMetrics.adaptive(12))
            .padding(.vertical, layoutMetrics.adaptive(8))
            .background(
                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(20), style: .continuous)
                    .fill(Color.white.opacity(0.18))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Timer")
        .accessibilityValue(Text(timeString(from: viewModel.remainingTime)))
        .accessibilityAddTraits(.isButton)
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Helper Functions
    /// Test simulation: answered = blue (match Learning), unanswered = gray.
    private func circleColor(for index: Int) -> Color {
        let isAnswered = viewModel.answers.contains(where: { $0.questionId == viewModel.questions[index].id })
        if isAnswered {
            return Color("AppBlueLagoon")
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

