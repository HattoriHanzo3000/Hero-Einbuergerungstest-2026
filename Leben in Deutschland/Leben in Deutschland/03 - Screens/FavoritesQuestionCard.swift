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
    @State private var lastHorizontalScrollHapticTs: Double = 0
    
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

// MARK: - Header View
private extension FavoritesQuestionCard {
    var headerView: some View {
        QuestionCardHeader(
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
    
    /// Same nav row as TestAnswersView/LearningView: back + scrollable circles (under separators) + forward. Gray when not selected (no correct/wrong).
    private func questionNavigationBar(onGoToQuestion: @escaping (Int) -> Void) -> some View {
        let navigationCircleSize = layoutMetrics.adaptive(34)
        let currentZeroBased = progress.currentIndex - 1
        return ScrollViewReader { proxy in
            HStack(spacing: layoutMetrics.adaptive(12)) {
                // Back arrow
                Button(action: {
                    HapticManager.shared.lightImpact()
                    if currentZeroBased > 0 {
                        onGoToQuestion(currentZeroBased - 1)
                    }
                }) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: layoutMetrics.adaptive(16), weight: .semibold))
                        .foregroundColor(currentZeroBased > 0 ? .white : Color.white.opacity(0.5))
                        .frame(width: navigationCircleSize, height: navigationCircleSize)
                        .background(Circle().fill(Color("AppBlueLagoon")))
                }
                .disabled(currentZeroBased <= 0)
                .buttonStyle(.plain)
                .accessibilityLabel("Previous question")
                .accessibilityHint("Go to previous question")
                
                // Scrollable circles under vertical separators
                ZStack(alignment: .center) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<progress.totalCount, id: \.self) { index in
                                Button(action: {
                                    HapticManager.shared.lightImpact()
                                    onGoToQuestion(index)
                                }) {
                                    Circle()
                                        .fill(circleColor(for: index))
                                        .frame(width: navigationCircleSize, height: navigationCircleSize)
                                        .overlay(
                                            Text("\(index + 1)")
                                                .font(.system(size: layoutMetrics.adaptive(14), weight: .semibold))
                                                .foregroundColor(circleTextColor(for: index))
                                        )
                                }
                                .id(index)
                            }
                        }
                        .padding(.horizontal, 0)
                    }
                    .onChange(of: progress.currentIndex) { _, newIndex in
                        withAnimation {
                            proxy.scrollTo(newIndex - 1, anchor: .center)
                        }
                        HapticManager.shared.lightImpact()
                    }
                    .simultaneousGesture(DragGesture().onChanged { _ in
                        let now = Date().timeIntervalSince1970
                        if now - lastHorizontalScrollHapticTs > 0.2 {
                            lastHorizontalScrollHapticTs = now
                            HapticManager.shared.lightImpact()
                        }
                    })
                    
                    HStack {
                        navigationBarVerticalSeparator(size: navigationCircleSize)
                        Spacer(minLength: 0)
                        navigationBarVerticalSeparator(size: navigationCircleSize)
                    }
                    .frame(height: navigationCircleSize)
                    .allowsHitTesting(false)
                }
                .frame(maxWidth: .infinity)
                
                // Forward arrow
                Button(action: {
                    HapticManager.shared.lightImpact()
                    if currentZeroBased < progress.totalCount - 1 {
                        onGoToQuestion(currentZeroBased + 1)
                    }
                }) {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: layoutMetrics.adaptive(16), weight: .semibold))
                        .foregroundColor(currentZeroBased < progress.totalCount - 1 ? .white : Color.white.opacity(0.5))
                        .frame(width: navigationCircleSize, height: navigationCircleSize)
                        .background(Circle().fill(Color("AppBlueLagoon")))
                }
                .disabled(currentZeroBased >= progress.totalCount - 1)
                .buttonStyle(.plain)
                .accessibilityLabel("Next question")
                .accessibilityHint("Go to next question")
            }
            .padding(.horizontal, layoutMetrics.adaptive(24))
            .frame(height: navigationCircleSize + layoutMetrics.adaptive(8))
            .padding(.bottom, layoutMetrics.adaptive(16))
        }
    }
    
    private func navigationBarVerticalSeparator(size: CGFloat) -> some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(width: 1)
            .frame(height: size)
    }
    
    /// Favorites: selected = blue, not selected = gray (no correct/wrong).
    private func circleColor(for index: Int) -> Color {
        if index == progress.currentIndex - 1 {
            return Color("AppBlueLagoon")
        }
        return Color(.systemGray5)
    }
    
    /// Favorites: white on selected (blue), primary on gray.
    private func circleTextColor(for index: Int) -> Color {
        if index == progress.currentIndex - 1 {
            return .white
        }
        return .primary
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
