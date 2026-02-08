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
    
    struct ZoomedAsset: Identifiable {
        let id = UUID()
        let name: String
    }
    
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
            FavoritesFullScreenImageView(assetName: item.name, onDismiss: {
                zoomedAsset = nil
            })
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

// MARK: - Full Screen Image View (matches LearningView)
private struct FavoritesFullScreenImageView: View {
    let assetName: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .onTapGesture {
                    HapticManager.shared.lightImpact()
                    onDismiss()
                }
            
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
            
            ZoomableImage(imageName: assetName)
                .padding(.horizontal, 20)
                .padding(.vertical, 60)
        }
        .transition(.opacity)
    }
}

// MARK: - Header View (matches LearningView)
private extension FavoritesQuestionCard {
    var headerView: some View {
        headerContent
            .padding(.vertical, layoutMetrics.adaptive(18))
            .padding(.horizontal, layoutMetrics.adaptive(20))
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(liquidGlassBackground)
            .clipShape(headerRoundedRectangle)
            .overlay(headerBorderOverlay)
            .padding(.horizontal)
            .padding(.top, layoutMetrics.adaptive(8))
    }
    
    private var headerContent: some View {
        VStack(alignment: .leading, spacing: layoutMetrics.adaptive(16)) {
            if let onBackTapped {
                HStack {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        onBackTapped()
                    }) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: layoutMetrics.adaptive(20), weight: .semibold))
                            .foregroundColor(.white)
                            .padding(layoutMetrics.adaptive(10))
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.18))
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("back_button_accessibility_label".localized)
                    
                    Spacer()
                    
                    PremiumCrownButton(action: { premiumManager.presentPaywall() }, color: .white)
                }
            }
            
            // Topic title (subcategory or category)
            Text((question.subcategory ?? "").isEmpty ? (question.category ?? "Favorites") : (question.subcategory ?? ""))
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
            
            // Progress bar
            ProgressView(
                value: Double(progress.currentIndex),
                total: max(Double(progress.totalCount), 1)
            )
            .progressViewStyle(LinearProgressViewStyle(tint: Color(.systemGray6)))
            .frame(height: layoutMetrics.adaptive(8))
            .clipShape(Capsule())
            
            // Question ID + Actions
            questionHeaderRow
        }
    }
    
    private var questionHeaderRow: some View {
        HStack {
            HStack(spacing: 8) {
                Text("question_label".localized + " \(question.id)")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.white)
                    .accessibilityLabel("question_label".localized + " " + question.id)
                
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
    
    private var headerRoundedRectangle: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: layoutMetrics.adaptive(32),
            style: .continuous
        )
    }
    
    private var headerBorderOverlay: some View {
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
                questionNavigationBar(onGoToQuestion: onGoToQuestion)
            }
        }
        .padding(.top, layoutMetrics.adaptive(12))
        .padding(.bottom, layoutMetrics.adaptive(24))
        .background(Color(.systemBackground))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showCorrectAnswer)
    }
    
    func hintAction() {
        HapticManager.shared.lightImpact()
        showingHintSheet = true
    }
    
    private func questionNavigationBar(onGoToQuestion: @escaping (Int) -> Void) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<progress.totalCount, id: \.self) { index in
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            onGoToQuestion(index)
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
                .padding(.horizontal, layoutMetrics.adaptive(24))
            }
            .frame(height: 44)
            .padding(.bottom, layoutMetrics.adaptive(16))
            .onChange(of: progress.currentIndex) { _, newIndex in
                withAnimation {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
    }
    
    private func circleColor(for index: Int) -> Color {
        // In favorites, only show selected/not selected (no correct/wrong highlighting)
        if index == progress.currentIndex - 1 {
            return Color("SelectedCircle")
        } else {
            return Color(.systemGray5)
        }
    }
    
    private func circleTextColor(for index: Int) -> Color {
        // In favorites, only show selected/not selected (no correct/wrong highlighting)
        if index == progress.currentIndex - 1 {
            return Color(.systemGray6)
        } else {
            return .primary
        }
    }
}

// MARK: - Hint Icon Button (matches LearningView)
private struct HintIconButton: View {
    let action: () -> Void
    @Environment(\.layoutMetrics) private var layoutMetrics
    
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
