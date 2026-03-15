//
//  AllQuestionsQuestionCard.swift
//  Leben in Deutschland
//
//  Question card for All Questions reading mode. Shows question, answers, and correct answer.
//  Design blends Spaced Repetition colors, Learning view nav bar, and Favorites reading mode.
//

import SwiftUI

// MARK: - All Questions Question Card
struct AllQuestionsQuestionCard: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    @State private var showingFeedbackReport = false
    @State private var zoomedAsset: ZoomedAsset?

    let question: QuestionModel
    let showTranslation: Bool
    let currentIndex: Int
    let totalCount: Int
    let onBackTapped: (() -> Void)?
    let onToggleTranslation: (() -> Void)?
    let isTranslationActive: Bool
    let onToggleFavorite: (() -> Void)?
    let isFavorite: Bool
    let onGoToQuestion: (Int) -> Void

    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.bottom, layoutMetrics.adaptive(12))

            Divider()
                .background(Color(.separator))

            questionScrollView
            footerView
        }
        .background(Color(.systemBackground).ignoresSafeArea(edges: .bottom))
        .fullScreenCover(item: $zoomedAsset) { item in
            FullScreenImageView(assetName: item.name, onDismiss: { zoomedAsset = nil })
        }
        .sheet(isPresented: $showingFeedbackReport) {
            FeedbackReportView(
                questionId: question.id,
                questionText: question.text,
                category: question.category
            )
            .environmentObject(languageManager)
        }
    }
}

// MARK: - Header View
private extension AllQuestionsQuestionCard {
    var headerView: some View {
        QuestionCardHeaderCard(
            onBackTapped: onBackTapped,
            title: "home_learn_all_questions".localized,
            progress: (currentIndex + 1, totalCount),
            questionId: question.id,
            onReportTapped: { showingFeedbackReport = true },
            showPremiumButton: true,
            isPremium: subscriptionManager.effectiveIsPremium,
            trailingActions: { EmptyView() }
        )
    }
}

// MARK: - Question Content
private extension AllQuestionsQuestionCard {
    var questionScrollView: some View {
        ScrollView {
            let assetName = ContentService.shared.getIllustrationAsset(for: question.id)
            QuestionCard(
                question: question,
                selectedAnswer: nil,
                showCorrectAnswer: true,
                showTranslation: showTranslation,
                onAnswerSelected: { _ in },
                illustrationAssetName: assetName,
                onImageTapped: {
                    guard let assetName = assetName else { return }
                    HapticManager.shared.lightImpact()
                    zoomedAsset = ZoomedAsset(name: assetName)
                },
                suppressAnswerGlow: true,
                suppressIncorrectHighlight: true
            )
            .padding(.bottom, layoutMetrics.adaptive(16))
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
}

// MARK: - Footer View
private extension AllQuestionsQuestionCard {
    var footerView: some View {
        VStack(spacing: layoutMetrics.adaptive(LayoutMetrics.footerSectionSpacing)) {
            HStack(spacing: layoutMetrics.adaptive(12)) {
                Spacer(minLength: 0)
                translationFooterButton
                favoriteFooterButton
            }
            .padding(.horizontal, layoutMetrics.adaptive(LayoutMetrics.footerHorizontalPadding))

            // Next button above navigation circles
            if totalCount >= 1 {
                QuizActionButton(
                    "next_button".localized,
                    style: nextButtonStyle,
                    isEnabled: currentIndex < totalCount - 1,
                    accessibilityLabel: "next_button".localized
                ) {
                    HapticManager.shared.lightImpact()
                    if currentIndex < totalCount - 1 {
                        onGoToQuestion(currentIndex + 1)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, layoutMetrics.adaptive(LayoutMetrics.footerHorizontalPadding))
            }

            if totalCount >= 1 {
                QuestionNavigationBar(
                    questionCount: totalCount,
                    currentIndex: currentIndex,
                    circleColor: { _ in Color(.systemGray5) },
                    circleTextColor: { $0 == currentIndex ? .white : .primary },
                    onPrevious: {
                        if currentIndex > 0 {
                            onGoToQuestion(currentIndex - 1)
                        }
                    },
                    onNext: {
                        if currentIndex < totalCount - 1 {
                            onGoToQuestion(currentIndex + 1)
                        }
                    },
                    onSelectIndex: onGoToQuestion,
                    gradient: .blue,
                    circleUsesGradient: { $0 == currentIndex },
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
            onToggleTranslation?()
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
        Button(action: {
            HapticManager.shared.lightImpact()
            onToggleFavorite?()
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

    private var nextButtonStyle: QuizActionButton.Style {
        QuizActionButton.Style(
            backgroundColor: Color("AppBlueLagoon"),
            disabledBackgroundColor: Color(.systemGray2),
            haloPrimaryColor: Color("AppBlueLagoon").opacity(0.36),
            haloSecondaryColor: Color.white.opacity(0.18),
            suppressGlow: true,
            gradient: .blue
        )
    }
}

// MARK: - Preview
#Preview {
    let sampleQuestion = QuestionModel(
        id: "001",
        text: "Welches Grundrecht steht allen Menschen in Deutschland zu?",
        options: [
            "Das Recht auf freie Meinungsäußerung",
            "Das Recht auf Steuerbefreiung",
            "Das Recht auf kostenlose Verkehrstickets",
            "Das Recht auf eine Luxuswohnung"
        ],
        hint: nil,
        category: "Grundrechte",
        subcategory: nil
    )

    AllQuestionsQuestionCard(
        question: sampleQuestion,
        showTranslation: false,
        currentIndex: 0,
        totalCount: 310,
        onBackTapped: {},
        onToggleTranslation: {},
        isTranslationActive: false,
        onToggleFavorite: {},
        isFavorite: false,
        onGoToQuestion: { _ in }
    )
    .environmentObject(LanguageManager())
    .environmentObject(SubscriptionManager.shared)
    .background(Color(.systemGroupedBackground))
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
