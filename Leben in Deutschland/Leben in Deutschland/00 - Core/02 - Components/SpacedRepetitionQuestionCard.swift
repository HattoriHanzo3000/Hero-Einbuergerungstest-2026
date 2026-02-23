import SwiftUI

// MARK: - Spaced Repetition Question Card
/// Mirrors the Learn question card layout but trims navigation controls for spaced repetition drills.
struct SpacedRepetitionQuestionCard: View {
    // MARK: - Models
    struct ProgressState {
        let answeredCount: Int
        let totalCount: Int
    }
    
    // MARK: - Inputs
    let question: QuestionModel
    let selectedAnswer: Int?
    let showCorrectAnswer: Bool
    let showTranslation: Bool
    let progress: ProgressState?
    let onAnswerSelected: (Int) -> Void
    let onBackTapped: (() -> Void)?
    let onToggleTranslation: (() -> Void)?
    let isTranslationActive: Bool
    let onToggleFavorite: (() -> Void)?
    let isFavorite: Bool
    let onCheckTapped: (() -> Void)?
    let isCheckEnabled: Bool

    init(
        question: QuestionModel,
        selectedAnswer: Int?,
        showCorrectAnswer: Bool,
        showTranslation: Bool,
        progress: ProgressState?,
        onAnswerSelected: @escaping (Int) -> Void,
        onBackTapped: (() -> Void)? = nil,
        onToggleTranslation: (() -> Void)? = nil,
        isTranslationActive: Bool = false,
        onToggleFavorite: (() -> Void)? = nil,
        isFavorite: Bool = false,
        onCheckTapped: (() -> Void)? = nil,
        isCheckEnabled: Bool = true
    ) {
        self.question = question
        self.selectedAnswer = selectedAnswer
        self.showCorrectAnswer = showCorrectAnswer
        self.showTranslation = showTranslation
        self.progress = progress
        self.onAnswerSelected = onAnswerSelected
        self.onBackTapped = onBackTapped
        self.onToggleTranslation = onToggleTranslation
        self.isTranslationActive = isTranslationActive
        self.onToggleFavorite = onToggleFavorite
        self.isFavorite = isFavorite
        self.onCheckTapped = onCheckTapped
        self.isCheckEnabled = isCheckEnabled
    }
    
    // MARK: - Dependencies
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var premiumManager: PremiumManager
    @State private var showingFeedbackReport = false
    @State private var showingHintSheet = false
    @State private var zoomedAsset: ZoomedAsset?
    private let hintService = HintService.shared
    private let contentService = ContentService.shared
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.bottom, layoutMetrics.adaptive(12))
            Divider()
                .background(Color(.separator))
            ScrollView {
                let assetName = contentService.getIllustrationAsset(for: question.id)
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
                    suppressAnswerGlow: true
                )
                .padding(.bottom, layoutMetrics.adaptive(16))
            }
            .background(Color(.systemBackground))
            Divider()
                .background(Color(.separator))
            footerContent
        }
        .background(Color(.systemBackground))
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

// MARK: - Private Behaviour
private extension SpacedRepetitionQuestionCard {
    var buttonTitle: String {
        showCorrectAnswer ? "next_button".localized : "check_answer_button".localized
    }
    
    var checkButtonAccessibilityLabel: String {
        showCorrectAnswer ? "next_button".localized : "check_answer_button_accessibility_label".localized
    }
    
    var checkButtonStyle: QuizActionButton.Style {
        QuizActionButton.Style(
            backgroundColor: Color("AppBlueLagoon"),
            disabledBackgroundColor: Color(.systemGray2),
            haloPrimaryColor: Color("AppBlueLagoon").opacity(0.36),
            haloSecondaryColor: Color.white.opacity(0.18),
            showsHaloWhenDisabled: showCorrectAnswer,
            suppressGlow: true
        )
    }
    
    func hintAction() {
        showingHintSheet = true
    }
}

// MARK: - Private UI
private extension SpacedRepetitionQuestionCard {
    var footerContent: some View {
        HStack(spacing: layoutMetrics.adaptive(12)) {
            if showCorrectAnswer, hintService.getHint(for: question.id) != nil {
                HintIconButton(action: hintAction)
                    .transition(.scale.combined(with: .opacity))
            }
            if let onCheckTapped {
                QuizActionButton(
                    buttonTitle,
                    style: checkButtonStyle,
                    isEnabled: isCheckEnabled,
                    accessibilityLabel: checkButtonAccessibilityLabel
                ) {
                    onCheckTapped()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, layoutMetrics.adaptive(24))
        .padding(.top, layoutMetrics.adaptive(12))
        .padding(.bottom, layoutMetrics.adaptive(24))
        .background(Color(.systemBackground))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showCorrectAnswer)
    }
    
    var headerView: some View {
        QuestionCardHeaderCard(
            onBackTapped: onBackTapped,
            showPremiumButton: onBackTapped != nil,
            onPremiumTap: { premiumManager.presentPaywall() },
            title: nil,
            progress: progress.map { ($0.answeredCount, $0.totalCount) },
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
        category: "Grundrechte",
        subcategory: "Meinungsfreiheit"
    )
    
    SpacedRepetitionQuestionCard(
        question: sampleQuestion,
        selectedAnswer: nil,
        showCorrectAnswer: false,
        showTranslation: false,
        progress: .init(answeredCount: 4, totalCount: 20),
        onAnswerSelected: { _ in },
        onBackTapped: {},
        onToggleTranslation: {},
        isTranslationActive: true,
        onToggleFavorite: {},
        isFavorite: true,
        onCheckTapped: {},
        isCheckEnabled: true
    )
    .environmentObject(LanguageManager())
    .environmentObject(PremiumManager.shared)
    .background(Color(.systemGroupedBackground))
}
