import SwiftUI

// MARK: - Spaced Repetition Question Card
/// Mirrors the Learn question card layout but trims navigation controls for spaced repetition drills.
struct SpacedRepetitionQuestionCard: View {
    struct ProgressState {
        let answeredCount: Int
        let totalCount: Int
    }
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var premiumManager: PremiumManager
    
    @State private var showingFeedbackReport = false
    @State private var showingHintSheet = false
    
    private let hintService = HintService.shared
    
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
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
                .padding(.bottom, layoutMetrics.adaptive(12))
            Divider()
                .background(Color(.separator))
            ScrollView {
                QuestionCard(
                    question: question,
                    selectedAnswer: selectedAnswer,
                    showCorrectAnswer: showCorrectAnswer,
                    showTranslation: showTranslation,
                    onAnswerSelected: onAnswerSelected,
                    suppressAnswerGlow: true
                )
                .padding(.bottom, layoutMetrics.adaptive(16))
            }
            .background(Color(.systemBackground))
            Divider()
                .background(Color(.separator))
            HStack(spacing: layoutMetrics.adaptive(12)) {
                // Hint button (appears when answer is shown and hint exists)
                if showCorrectAnswer, hintService.getHint(for: question.id) != nil {
                    HintIconButton(action: hintAction)
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Check/Next button (shrinks when hint appears)
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
        .background(Color(.systemBackground))
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

private extension SpacedRepetitionQuestionCard {
    private var buttonTitle: String {
        showCorrectAnswer ? "next_button".localized : "check_answer_button".localized
    }
    
    private var checkButtonAccessibilityLabel: String {
        if showCorrectAnswer {
            // Use the button title itself as accessibility label for "Next" button
            return "next_button".localized
        } else {
            return "check_answer_button_accessibility_label".localized
        }
    }
    
    private var checkButtonStyle: QuizActionButton.Style {
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
        HapticManager.shared.lightImpact()
        print("🔍 Looking for hint for question ID: \(question.id)")
        print("🔍 Available hints count: \(hintService.hints.count)")
        print("🔍 Hint service isLoading: \(hintService.isLoading)")
        
        if hintService.getHint(for: question.id) != nil {
            print("✅ Found hint for question \(question.id)")
        } else {
            print("⚠️ No hint available for question \(question.id)")
            print("⚠️ Available question IDs in hints: \(Array(hintService.hints.keys).prefix(5))")
        }
        
        // Always show the sheet (with hint or fallback message)
        showingHintSheet = true
    }
    
    private var hintButtonStyle: QuizActionButton.Style {
        QuizActionButton.Style(
            backgroundColor: Color(uiColor: .systemOrange),
            disabledBackgroundColor: Color(uiColor: .systemOrange),
            haloPrimaryColor: Color(uiColor: .systemOrange).opacity(0.42),
            haloSecondaryColor: Color.white.opacity(0.18),
            showsHaloWhenDisabled: true
        )
    }
}

// MARK: - Hint Icon Button
private struct HintIconButton: View {
    let action: () -> Void
    @Environment(\.layoutMetrics) private var layoutMetrics
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            action()
        }) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: layoutMetrics.adaptive(20), weight: .semibold))
                .foregroundColor(.white)
                .padding(.vertical, layoutMetrics.adaptive(18))
                .frame(width: layoutMetrics.adaptive(80))
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(28), style: .continuous)
                            .fill(.ultraThinMaterial)
                        
                        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(28), style: .continuous)
                            .fill(Color("AppOrange"))
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(28), style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
                )
                .shadow(
                    color: Color.black.opacity(0.16),
                    radius: layoutMetrics.adaptive(22),
                    y: layoutMetrics.adaptive(10)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("hint_button_title".localized)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Header
private extension SpacedRepetitionQuestionCard {
    var headerView: some View {
        QuestionCardHeader(
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
                        QuizHeaderIconButton(
                            systemName: "globe",
                            isActive: isTranslationActive,
                            activeTint: Color("AppOrange"),
                            inactiveTint: .white,
                            showGlow: false,
                            showStroke: false,
                            accessibilityLabel: "spaced_translation_button_accessibility_label".localized,
                            accessibilityHint: nil,
                            action: onToggleTranslation
                        )
                    }
                    if let onToggleFavorite {
                        QuizHeaderIconButton(
                            systemName: "heart",
                            isActive: isFavorite,
                            activeTint: Color("AppPink"),
                            inactiveTint: .white,
                            showGlow: false,
                            showStroke: false,
                            useFilledWhenActive: true,
                            accessibilityLabel: "spaced_favorite_button_accessibility_label".localized,
                            accessibilityHint: nil,
                            action: onToggleFavorite
                        )
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
    .background(Color(.systemGroupedBackground))
}

