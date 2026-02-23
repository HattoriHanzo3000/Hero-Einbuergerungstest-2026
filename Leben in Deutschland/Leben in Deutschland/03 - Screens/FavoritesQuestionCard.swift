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
    @EnvironmentObject private var premiumManager: PremiumManager
    
    @State private var showingFeedbackReport = false
    @State private var showingHintSheet = false
    @State private var zoomedAsset: ZoomedAsset?
    
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
    let isCorrectAt: (Int) -> Bool
    let isIncorrectAt: (Int) -> Bool
    
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
        onGoToQuestion: ((Int) -> Void)? = nil,
        isCorrectAt: @escaping (Int) -> Bool = { _ in false },
        isIncorrectAt: @escaping (Int) -> Bool = { _ in false }
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
        self.isCorrectAt = isCorrectAt
        self.isIncorrectAt = isIncorrectAt
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.bottom, layoutMetrics.adaptive(12))
            
            Divider()
                .background(Color(.separator))
            
            questionContentView
            
            Divider()
                .background(Color(.separator))
            
            footerView
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(edges: .bottom)
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
            showPremiumButton: onBackTapped != nil,
            onPremiumTap: { premiumManager.presentPaywall() },
            title: (question.subcategory ?? "").isEmpty ? (question.category ?? "Favorites") : (question.subcategory ?? ""),
            progress: (progress.currentIndex, progress.totalCount),
            questionId: question.id,
            onReportTapped: { showingFeedbackReport = true },
            trailingActions: {
                HStack(spacing: layoutMetrics.adaptive(8)) {
                    if let onToggleTranslation {
                        QuizHeaderIconButton.translation(isActive: isTranslationActive, action: onToggleTranslation)
                    }
                    if let onToggleFavorite {
                        QuizHeaderIconButton.favorite(isActive: isFavorite, action: onToggleFavorite)
                    }
                }
            }
        )
        .padding(.bottom, layoutMetrics.adaptive(12))
    }
}

// MARK: - Question Content (matches LearningView)
private extension FavoritesQuestionCard {
    var questionContentView: some View {
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
    }
}

// MARK: - Footer View (matches LearningView)
private extension FavoritesQuestionCard {
    var footerView: some View {
        VStack(spacing: layoutMetrics.adaptive(8)) {
            // Hint button (appears when answer is shown and hint exists)
            if showCorrectAnswer, hintService.getHint(for: question.id) != nil {
                HStack {
                    HintIconButton(action: hintAction)
                        .transition(.scale.combined(with: .opacity))
                }
                .padding(.horizontal, layoutMetrics.adaptive(24))
            }
            
            if progress.totalCount > 1, let onGoToQuestion {
                QuestionNavigationBar(
                    questionCount: progress.totalCount,
                    currentIndex: progress.currentIndex - 1,
                    circleColor: circleColor(for:),
                    circleTextColor: circleTextColor(for:),
                    onPrevious: {
                        if progress.currentIndex > 1 {
                            onGoToQuestion(progress.currentIndex - 2)
                        }
                    },
                    onNext: {
                        if progress.currentIndex < progress.totalCount {
                            onGoToQuestion(progress.currentIndex)
                        }
                    },
                    onSelectIndex: onGoToQuestion,
                    enableScrollHaptic: true,
                    enableChangeHaptic: true
                )
            }
        }
        .padding(.top, layoutMetrics.adaptive(12))
        .background(Color(.systemBackground))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showCorrectAnswer)
    }
    
    func hintAction() {
        HapticManager.shared.lightImpact()
        showingHintSheet = true
    }
    
    /// Favorites: all gray (no correct/wrong). Active circle is larger, not blue.
    private func circleColor(for index: Int) -> Color {
        Color(.systemGray5)
    }
    
    /// Favorites: primary on gray (no white needed).
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
    .background(Color(.systemGroupedBackground))
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
