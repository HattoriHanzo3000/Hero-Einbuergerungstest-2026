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
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @State private var showingFeedbackReport = false
    @State private var showingHintSheet = false
    @State private var zoomedAsset: ZoomedAsset?
    @State private var hintBarGlowPhase = false
    @State private var hintBarRevealed = false
    private let hintService = HintService.shared
    private let contentService = ContentService.shared
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.bottom, layoutMetrics.adaptive(12))
            Divider()
                .background(Color(.separator))
            questionScrollView
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
            suppressGlow: true,
            gradient: .blue
        )
    }
    
    func hintAction() {
        showingHintSheet = true
    }
}

// MARK: - Private UI
private extension SpacedRepetitionQuestionCard {
    var questionScrollView: some View {
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

    var footerContent: some View {
        VStack(spacing: layoutMetrics.adaptive(LayoutMetrics.footerSectionSpacing)) {
            // Action bar: hint (left, when available, with pulse), translation + favorite (right)
            HStack(spacing: layoutMetrics.adaptive(12)) {
                if hintService.getHint(for: question.id) != nil {
                    hintFooterButton
                        .opacity(hintBarRevealed ? 1 : 0)
                        .scaleEffect(hintBarRevealed ? 1 : 0.85)
                        .transition(.scale.combined(with: .opacity))
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
            .onAppear {
                if hintService.getHint(for: question.id) != nil {
                    withAnimation(.easeOut(duration: 0.35)) { hintBarRevealed = true }
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        hintBarGlowPhase = true
                    }
                }
            }
            .onChange(of: question.id) { _, _ in
                hintBarRevealed = false
                hintBarGlowPhase = false
                if hintService.getHint(for: question.id) != nil {
                    withAnimation(.easeOut(duration: 0.35)) { hintBarRevealed = true }
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        hintBarGlowPhase = true
                    }
                }
            }

            HStack(spacing: layoutMetrics.adaptive(12)) {
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
            .padding(.horizontal, layoutMetrics.adaptive(LayoutMetrics.footerHorizontalPadding))
        }
        .padding(.top, layoutMetrics.adaptive(12))
        .background(Color(.systemBackground))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showCorrectAnswer)
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

    /// Hint button in action bar: same circle style, amber icon, pulsing amber glow (fade in/out).
    private var hintFooterButton: some View {
        let glowOpacity = hintBarGlowPhase ? 0.5 : 0.15
        return Button(action: {
            HapticManager.shared.lightImpact()
            hintAction()
        }) {
            footerIconCircle {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color("AppAmber"))
            }
            .overlay(
                Circle()
                    .fill(Color("AppAmber").opacity(glowOpacity))
                    .blur(radius: layoutMetrics.adaptive(6))
                    .scaleEffect(1.35)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("hint_button_title".localized)
        .accessibilityAddTraits(.isButton)
    }

    var headerView: some View {
        QuestionCardHeaderCard(
            onBackTapped: onBackTapped,
            title: question.subcategory ?? question.category,
            progress: progress.map { ($0.answeredCount, $0.totalCount) },
            questionId: question.id,
            onReportTapped: { showingFeedbackReport = true },
            showPremiumButton: true,
            isPremium: subscriptionManager.effectiveIsPremium,
            trailingActions: { EmptyView() }
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
    .environmentObject(SubscriptionManager.shared)
    .background(Color(.systemGroupedBackground))
}
