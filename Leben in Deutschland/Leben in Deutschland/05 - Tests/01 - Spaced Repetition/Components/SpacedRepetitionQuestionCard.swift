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
        ZStack(alignment: .bottom) {
            VStack(spacing: layoutMetrics.adaptive(20)) {
                headerView
                
                ScrollView {
                    QuestionCard(
                        question: question,
                        selectedAnswer: selectedAnswer,
                        showCorrectAnswer: showCorrectAnswer,
                        showTranslation: showTranslation,
                        onAnswerSelected: onAnswerSelected
                    )
                    .padding(.bottom, layoutMetrics.adaptive(80))
                }
            }
            .background(Color(.systemBackground))
            
            HStack(spacing: layoutMetrics.adaptive(12)) {
                // Hint button (appears when answer is shown)
                if showCorrectAnswer {
                    HintIconButton(action: hintAction)
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Check/Next button (shrinks when hint appears)
                if let onCheckTapped {
                    QuizActionButton(
                        buttonTitle,
                        style: checkButtonStyle,
                        isEnabled: isCheckEnabled,
                        accessibilityLabel: "check_answer_button_accessibility_label".localized
                    ) {
                        onCheckTapped()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, layoutMetrics.adaptive(24))
            .padding(.bottom, layoutMetrics.adaptive(24))
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
                HintSheetView(hint: hint)
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
    
    private var checkButtonStyle: QuizActionButton.Style {
        QuizActionButton.Style(
            backgroundColor: Color("AppBlueLagoon"),
            disabledBackgroundColor: Color(.systemGray2),
            haloPrimaryColor: Color("AppBlueLagoon").opacity(0.36),
            haloSecondaryColor: Color.white.opacity(0.18),
            showsHaloWhenDisabled: showCorrectAnswer
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
                .shadow(
                    color: colorScheme == .dark ? Color("AppOrange").opacity(0.42) : .clear,
                    radius: layoutMetrics.adaptive(26),
                    y: layoutMetrics.adaptive(10)
                )
                .shadow(
                    color: colorScheme == .dark ? Color.white.opacity(0.18) : .clear,
                    radius: layoutMetrics.adaptive(12),
                    y: layoutMetrics.adaptive(2)
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
        VStack(alignment: .leading, spacing: layoutMetrics.adaptive(16)) {
            if let onBackTapped {
                HStack {
                    Button(action: onBackTapped) {
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
            }
            
            if let progress {
                ProgressView(
                    value: Double(progress.answeredCount),
                    total: max(Double(progress.totalCount), 1)
                )
                .progressViewStyle(
                    LinearProgressViewStyle(tint: Color(.systemGray6))
                )
                .frame(height: layoutMetrics.adaptive(8))
                .clipShape(Capsule())
            }
            
            HStack {
                HStack(spacing: 8) {
                Text("question_label".localized + " \(question.id)")
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
                
                Spacer()
                
                if let onToggleTranslation {
                    QuizHeaderIconButton(
                        systemName: "globe",
                        isActive: isTranslationActive,
                        activeTint: .orange,
                        accessibilityLabel: "spaced_translation_button_accessibility_label".localized,
                        accessibilityHint: nil,
                        action: onToggleTranslation
                    )
                }
                
                if let onToggleFavorite {
                    QuizHeaderIconButton(
                        systemName: "heart",
                        isActive: isFavorite,
                        activeTint: .pink,
                        accessibilityLabel: "spaced_favorite_button_accessibility_label".localized,
                        accessibilityHint: nil,
                        action: onToggleFavorite
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

