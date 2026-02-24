//
//  TestResultsView.swift
//  Leben in Deutschland
//
//  View showing test results with pass/fail status and statistics
//

import SwiftUI

/// Ensures label text ends with ":" for left-side titles and category names.
private extension String {
    var withTrailingColon: String { hasSuffix(":") ? self : self + ":" }
}

struct TestResultsView: View {
    @ObservedObject var viewModel: TestSessionViewModel
    let onBackToMainMenu: () -> Void
    let onTryAgain: () -> Void
    var onStartTestLoading: (() -> Void)? = nil // Callback to start loading test during countdown
    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutMetrics) private var layoutMetrics
    @Environment(AppRouter.self) private var router
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var favoritesManager: FavoritesManager
    
    @State private var showingAnswers = false
    @State private var showingRetryCountdown = false
    @State private var showingQuitConfirmation = false
    
    private var results: TestResults {
        TestResults(
            correctAnswers: viewModel.correctCount,
            totalQuestions: viewModel.questions.count,
            isPassed: viewModel.isPassed,
            timeUsed: viewModel.timeUsed,
            answers: viewModel.answers
        )
    }
    
    private var resultColor: Color {
        if results.isPassed {
            return Color("AppGreen")
        } else {
            return Color(red: 0.9, green: 0.2, blue: 0.2)
        }
    }
    
    /// Gradient for header area (shared LiquidGlassGradient .green / .red).
    private var resultHeaderGradient: LinearGradient {
        (results.isPassed ? LiquidGlassGradient.green : .red).screenBackground
    }
    
    /// Try Again: matches result — green when passed, red when failed.
    private var tryAgainButtonStyle: QuizActionButton.Style {
        QuizActionButton.Style(
            backgroundColor: resultColor,
            disabledBackgroundColor: Color(.systemGray2),
            haloPrimaryColor: resultColor.opacity(0.36),
            haloSecondaryColor: Color.white.opacity(0.18),
            showsHaloWhenDisabled: false,
            suppressGlow: true
        )
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Hide results content when countdown is showing so it never flashes after countdown
            if !showingRetryCountdown {
                VStack(spacing: 0) {
                    // Fixed header: result-colored gradient behind card (red/green, same as card)
                    testResultsHeaderSection
                        .screenHeaderPadding(metrics: layoutMetrics)
                        .padding(.bottom, layoutMetrics.adaptive(12))
                        .background(
                            Rectangle()
                                .fill(resultHeaderGradient)
                                .ignoresSafeArea(edges: .top)
                        )

                    Divider()
                        .background(Color(.separator))

                    // Scrollable body: statistics sections
                    ScrollView {
                    VStack(spacing: layoutMetrics.adaptive(LayoutMetrics.sectionSpacing)) {
                        // Statistics Section: Summary + By Categories — two sections
                        VStack(spacing: layoutMetrics.adaptive(16)) {
                            // Section 1: Summary
                            SectionContainer(spacing: layoutMetrics.adaptive(12)) {
                                VStack(alignment: .leading, spacing: layoutMetrics.adaptive(12)) {
                                    Text("test_results_summary".localized)
                                        .font(.headline)
                                        .fontWidth(.compressed)
                                    HStack {
                                        Text("time_used".localized.withTrailingColon)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text(results.timeString)
                                            .font(.body.weight(.medium))
                                            .fontWidth(.compressed)
                                            .monospacedDigit()
                                    }
                                    HStack {
                                        Text("minimum_requirement".localized.withTrailingColon)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("17 \("of".localized) 33")
                                            .font(.body.weight(.medium))
                                            .fontWidth(.compressed)
                                            .monospacedDigit()
                                    }
                                    HStack {
                                        Text("your_result".localized.withTrailingColon)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("\(results.correctAnswers) \("of".localized) 33")
                                            .font(.body.weight(.medium))
                                            .fontWidth(.compressed)
                                            .monospacedDigit()
                                    }
                                    HStack {
                                        Text("accuracy".localized.withTrailingColon)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("\(Int(results.accuracy * 100))%")
                                            .font(.body.weight(.medium))
                                            .fontWidth(.compressed)
                                            .monospacedDigit()
                                    }
                                }
                            }

                            // Section 2: By Categories (breakdown only)
                            SectionContainer(spacing: layoutMetrics.adaptive(12)) {
                                VStack(alignment: .leading, spacing: layoutMetrics.adaptive(12)) {
                                    Text("test_results_category_breakdown".localized)
                                        .font(.headline)
                                        .fontWidth(.compressed)
                                    if !categoryBreakdown.isEmpty {
                                        ForEach(Array(categoryBreakdown.enumerated()), id: \.offset) { _, item in
                                            HStack {
                                                Text(item.name.localized(for: languageManager.currentAppLanguage))
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                Spacer()
                                                Text(String(format: "test_results_x_of_y".localized, item.correct, item.total))
                                                    .font(.body.weight(.medium))
                                                    .fontWidth(.compressed)
                                                    .monospacedDigit()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, layoutMetrics.adaptive(20))
                        .padding(.top, layoutMetrics.adaptive(20))
                        .padding(.bottom, layoutMetrics.adaptive(100)) // Space for bottom buttons
                    }
                }
                
                // Separator above buttons
                Divider()
                    .background(Color(.separator))
                
                // Buttons fixed at bottom
                VStack(spacing: layoutMetrics.adaptive(12)) {
                    QuizActionButton(
                        "try_again".localized,
                        style: tryAgainButtonStyle
                    ) {
                        HapticManager.shared.lightImpact()
                        // Start loading test immediately (during countdown)
                        onStartTestLoading?()
                        // Show countdown immediately from TestResultsView
                        showingRetryCountdown = true
                    }
                }
                .padding(.horizontal, layoutMetrics.adaptive(24))
                .padding(.top, layoutMetrics.adaptive(16))
                .padding(.bottom, 0)
                .background(
                    Color(.systemBackground)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: -4)
                )
            }
        }
        }
        .id(languageManager.currentAppLanguage)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .hidesTabBar()
        .tabBarHidden(true)
        .sheet(isPresented: $showingAnswers) {
            TestAnswersView(viewModel: viewModel)
                .environmentObject(languageManager)
                .environmentObject(favoritesManager)
        }
        .fullScreenCover(isPresented: $showingRetryCountdown) {
            TestCountdownView {
                // Only dismiss results; countdown is presented by results so it goes away with it
                onTryAgain()
            }
            .environmentObject(languageManager)
            .environmentObject(StateManager.shared)
            .interactiveDismissDisabled(true)
        }
        .alert("quit_test_title".localized, isPresented: $showingQuitConfirmation) {
            Button("cancel".localized, role: .cancel) {
                HapticManager.shared.lightImpact()
            }
            Button("quit_test".localized, role: .destructive) {
                HapticManager.shared.heavyImpact()
                onBackToMainMenu()
            }
        } message: {
            Text("quit_test_message".localized)
        }
    }
}

// MARK: - Category breakdown (via TestResultsCategoryService)
private extension TestResultsView {
    var categoryBreakdown: [TestResultsCategoryStat] {
        TestResultsCategoryService.computeBreakdown(
            questions: viewModel.questions,
            answers: viewModel.answers,
            languageCode: languageManager.currentAppLanguage
        )
    }
}

// MARK: - Header Island (matches Progress layout: title + message left, mascot right)
private extension TestResultsView {
    var testResultsHeaderSection: some View {
        let gradient: LiquidGlassGradient = results.isPassed ? .green : .red
        let mascotSize: CGFloat = layoutMetrics.adaptive(120)
        let mascotToContentSpacing: CGFloat = layoutMetrics.adaptive(16)
        let titleToMessageSpacing: CGFloat = layoutMetrics.adaptive(6)

        return HeaderCard(gradient: gradient, showPremiumButton: false) {
            VStack(alignment: .leading, spacing: layoutMetrics.adaptive(8)) {
                // Back arrow (quit with confirmation) + checklist (view answers), same design
                HStack {
                    AdaptiveIconButton.backButton(action: {
                        HapticManager.shared.lightImpact()
                        showingQuitConfirmation = true
                    }, tintColor: .white)
                    Spacer()
                    AdaptiveIconButton(
                        systemName: "checklist.checked",
                        action: { showingAnswers = true },
                        accessibilityLabel: "view_answers".localized,
                        tintColor: .white,
                        backgroundColor: Color.white.opacity(0.18),
                        sizePreset: .standard
                    )
                }
                .transaction { $0.animation = nil }

                HStack(alignment: .top, spacing: mascotToContentSpacing) {
                    // Left: title + result message (same font params as Progress state/slogan)
                    VStack(alignment: .leading, spacing: titleToMessageSpacing) {
                        Text(results.isPassed ? "test_passed".localized : "test_failed".localized)
                            .font(.system(.title, weight: .heavy))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text(results.isPassed
                             ? "\(results.correctAnswers) \("of".localized) \(results.totalQuestions) \("questions_correct".localized)"
                             : "\("test_result_only_prefix".localized) \(results.correctAnswers) \("of".localized) \(results.totalQuestions) \("questions_correct".localized)")
                            .font(.system(.body, weight: .semibold))
                            .italic()
                            .lineSpacing(4)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Right: mascot (same as Progress)
                    MascotView(autoPlayInterval: nil)
                        .frame(width: mascotSize, height: mascotSize)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Previews (real category names so breakdown matches app design)
private let previewCategoryNames = [
    "Law and Constitution",
    "History",
    "Federal States",
    "Elections",
    "Family and Education"
]

private func makePreviewResultsViewModel(passed: Bool) -> TestSessionViewModel {
    // 33 questions across categories to match real test; correctCount >= 17 when passed.
    let sampleQuestions: [TestQuestion] = (0..<33).map { i in
        TestQuestion(
            id: i,
            originalId: "\(100 + i)",
            text: "Sample question \(i + 1) text?",
            options: ["Option A", "Option B", "Option C", "Option D"],
            correctIndex: 0,
            isRegional: false,
            category: previewCategoryNames[i % previewCategoryNames.count]
        )
    }
    let vm = TestSessionViewModel()
    vm.initializeTest(generalQuestions: sampleQuestions, regionalQuestions: [])
    for i in 0..<vm.questions.count {
        vm.goToQuestion(i)
        let q = vm.questions[i]
        let chosen: Int
        if passed {
            chosen = q.correctIndex
        } else {
            // Vary by category index so breakdown differs across categories
            let catIndex = i % previewCategoryNames.count
            chosen = (catIndex % 3 == 0) ? q.correctIndex : (q.correctIndex + 1) % max(1, q.options.count)
        }
        vm.answerQuestion(selectedIndex: chosen)
    }
    vm.finishTest()
    return vm
}

#Preview("Test Results – Passed") {
    TestResultsView(
        viewModel: makePreviewResultsViewModel(passed: true),
        onBackToMainMenu: {},
        onTryAgain: {}
    )
    .environmentObject(LanguageManager())
    .environmentObject(FavoritesManager.shared)
    .environment(AppRouter())
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

#Preview("Test Results – Failed") {
    TestResultsView(
        viewModel: makePreviewResultsViewModel(passed: false),
        onBackToMainMenu: {},
        onTryAgain: {}
    )
    .environmentObject(LanguageManager())
    .environmentObject(FavoritesManager.shared)
    .environment(AppRouter())
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
