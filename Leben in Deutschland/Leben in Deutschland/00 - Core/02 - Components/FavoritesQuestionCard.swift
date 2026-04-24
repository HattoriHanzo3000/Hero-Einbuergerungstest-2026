//
//  FavoritesQuestionCard.swift
//  Leben in Deutschland
//
//  Question card component for favorites - matches LearningView design
//

import SwiftUI

// MARK: - Favorites Question Card
struct FavoritesQuestionCard: View {
    struct ProgressState {
        let currentIndex: Int
        let totalCount: Int
    }
    
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    
    @State private var showingFeedbackReport = false
    @State private var showingHintSheet = false
    @State private var zoomedAsset: ZoomedAsset?
    @State private var hintGlowPhase = false
    
    private let hintService = HintService.shared
    
    let question: QuestionModel
    let selectedAnswer: Int?
    let showCorrectAnswer: Bool
    let showTranslation: Bool
    let progress: ProgressState
    let onAnswerSelected: (Int) -> Void
    let onBackTapped: (() -> Void)?
    let onToggleTranslation: (() -> Void)?
    let isTranslationActive: Bool
    let onToggleFavorite: (() -> Void)?
    let isFavorite: Bool
    let onGoToQuestion: ((Int) -> Void)?
    
    init(
        question: QuestionModel,
        selectedAnswer: Int?,
        showCorrectAnswer: Bool,
        showTranslation: Bool,
        currentIndex: Int,
        totalCount: Int,
        onAnswerSelected: @escaping (Int) -> Void,
        onBackTapped: (() -> Void)? = nil,
        onToggleTranslation: (() -> Void)? = nil,
        isTranslationActive: Bool = false,
        onToggleFavorite: (() -> Void)? = nil,
        isFavorite: Bool = false,
        onGoToQuestion: ((Int) -> Void)? = nil
    ) {
        self.question = question
        self.selectedAnswer = selectedAnswer
        self.showCorrectAnswer = showCorrectAnswer
        self.showTranslation = showTranslation
        self.progress = ProgressState(currentIndex: currentIndex, totalCount: totalCount)
        self.onAnswerSelected = onAnswerSelected
        self.onBackTapped = onBackTapped
        self.onToggleTranslation = onToggleTranslation
        self.isTranslationActive = isTranslationActive
        self.onToggleFavorite = onToggleFavorite
        self.isFavorite = isFavorite
        self.onGoToQuestion = onGoToQuestion
    }
    
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
        .sheet(isPresented: $showingHintSheet) {
            if let hint = hintService.getHint(for: question.id) {
                HintSheetView(
                    hint: hint,
                    translatedHint: showTranslation && languageManager.currentTranslationLanguage != languageManager.currentAppLanguage
                        ? hintService.getTranslationHint(for: question.id)
                        : nil
                )
            } else {
                HintSheetView(hint: "no_hint_available".localized)
            }
        }
    }
}

// MARK: - Header View
private extension FavoritesQuestionCard {
    var headerView: some View {
        QuestionCardHeaderCard(
            onBackTapped: onBackTapped,
            title: (question.subcategory ?? "").isEmpty ? (question.category ?? "Favorites") : (question.subcategory ?? ""),
            progress: (progress.currentIndex, progress.totalCount),
            questionId: question.id,
            onReportTapped: { showingFeedbackReport = true },
            showProBadge: true,
            isProUser: subscriptionManager.effectiveIsPro,
            trailingActions: { EmptyView() }
        )
    }
}

// MARK: - Question Content (scroll + bottom gradient dissolve)
private extension FavoritesQuestionCard {
    var questionScrollView: some View {
        ScrollView {
            let assetName = ContentService.shared.getIllustrationAsset(for: question.id)
            QuestionCard(
                question: question,
                selectedAnswer: selectedAnswer,
                showCorrectAnswer: showCorrectAnswer,
                showTranslation: showTranslation,
                onAnswerSelected: onAnswerSelected,
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

// MARK: - Footer View (action bar + hint + nav, same style as LearningView / SpacedRepetition)
private extension FavoritesQuestionCard {
    var footerView: some View {
        VStack(spacing: layoutMetrics.adaptive(LayoutMetrics.footerSectionSpacing)) {
            // Action bar: hint (left, when available), translation + favorite (right)
            HStack(spacing: layoutMetrics.adaptive(12)) {
                if showCorrectAnswer, hintService.getHint(for: question.id) != nil {
                    hintFooterButton
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                }
                Spacer(minLength: 0)
                if onToggleTranslation != nil {
                    translationFooterButton
                }
                if onToggleFavorite != nil {
                    favoriteFooterButton
                }
            }
            .padding(.horizontal, layoutMetrics.adaptive(LayoutMetrics.footerHorizontalPadding))

            if progress.totalCount >= 1, let onGoToQuestion {
                let current0Based = progress.currentIndex - 1
                QuestionNavigationBar(
                    questionCount: progress.totalCount,
                    currentIndex: current0Based,
                    circleColor: circleColor(for:),
                    circleTextColor: { $0 == current0Based ? .white : .primary },
                    onPrevious: {
                        if current0Based > 0 {
                            onGoToQuestion(current0Based - 1)
                        }
                    },
                    onNext: {
                        if current0Based < progress.totalCount - 1 {
                            onGoToQuestion(current0Based + 1)
                        }
                    },
                    onSelectIndex: onGoToQuestion,
                    gradient: .blue,
                    circleUsesGradient: { $0 == current0Based },
                    arrowCircleSize: layoutMetrics.adaptive(46),
                    enableScrollHaptic: true,
                    enableChangeHaptic: true
                )
            }
        }
        .padding(.top, layoutMetrics.adaptive(12))
        .background(Color(.systemBackground))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showCorrectAnswer)
        .onChange(of: showCorrectAnswer) { _, isRevealed in
            if !isRevealed { hintGlowPhase = false }
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

    func hintAction() {
        showingHintSheet = true
    }

    private func circleColor(for index: Int) -> Color {
        Color(.systemGray5)
    }

    private func circleTextColor(for index: Int) -> Color {
        .primary
    }
}

// MARK: - Preview
#Preview("Favorites Question Card") {
    let sampleQuestion = QuestionModel(
        id: "001",
        text: "What is the capital of Germany?",
        options: ["Berlin", "Munich", "Hamburg", "Frankfurt"],
        hint: nil,
        category: "Geography",
        subcategory: "Cities"
    )
    
    FavoritesQuestionCard(
        question: sampleQuestion,
        selectedAnswer: nil,
        showCorrectAnswer: false,
        showTranslation: false,
        currentIndex: 1,
        totalCount: 5,
        onAnswerSelected: { _ in },
        onBackTapped: {},
        onToggleTranslation: {},
        isTranslationActive: true,
        onToggleFavorite: {},
        isFavorite: true,
    )
    .environmentObject(LanguageManager())
    .environmentObject(SubscriptionManager.shared)
    .background(Color(.systemGroupedBackground))
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
