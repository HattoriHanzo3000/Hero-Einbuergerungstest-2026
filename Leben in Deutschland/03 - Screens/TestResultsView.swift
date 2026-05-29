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
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    
    @State private var showingAnswers = false
    @State private var showingRetryCountdown = false
    
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
    
    /// Try Again: matches result and header — green when passed, red when failed, with same gradient as header.
    private var tryAgainButtonStyle: QuizActionButton.Style {
        QuizActionButton.Style(
            backgroundColor: resultColor,
            disabledBackgroundColor: Color(.systemGray2),
            haloPrimaryColor: resultColor.opacity(0.36),
            haloSecondaryColor: Color.white.opacity(0.18),
            showsHaloWhenDisabled: false,
            suppressGlow: true,
            gradient: results.isPassed ? .green : .red
        )
    }
    
    var body: some View {
        Group {
            if showingRetryCountdown {
                Color(.systemBackground).ignoresSafeArea()
            } else {
                VStack(spacing: 0) {
                    testResultsHeaderSection
                        .padding(.horizontal, layoutMetrics.adaptive(16))
                        .padding(.bottom, layoutMetrics.adaptive(12))
                        .background(
                            Rectangle()
                                .fill(resultHeaderGradient)
                                .ignoresSafeArea(edges: .top)
                        )
                    Divider()
                        .background(Color(.separator))
                    resultsBodyView
                    resultsFooterView
                }
                .background(Color(.systemBackground))
            }
        }
        .id(languageManager.currentAppLanguage)
        .navigationBarTitleDisplayMode(.inline)
        .hidesLearningChrome()
        .sheet(isPresented: $showingAnswers) {
            NavigationStack {
                TestAnswersView(viewModel: viewModel)
                    .environmentObject(languageManager)
                    .environmentObject(favoritesManager)
                    .environmentObject(subscriptionManager)
            }
        }
        .fullScreenCover(isPresented: $showingRetryCountdown) {
            TestCountdownView {
                // Only dismiss results; countdown is presented by results so it goes away with it
                onTryAgain()
            }
            .environmentObject(languageManager)
            .environmentObject(StateManager.shared)
            .environmentObject(subscriptionManager)
            .interactiveDismissDisabled(true)
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

// MARK: - Header (content directly on gradient; padding applied at section level)
private extension TestResultsView {
    var testResultsHeaderSection: some View {
        let mascotSize: CGFloat = layoutMetrics.adaptive(120)
        let mascotToContentSpacing: CGFloat = layoutMetrics.adaptive(16)
        let titleToMessageSpacing: CGFloat = layoutMetrics.adaptive(6)

        return VStack(alignment: .leading, spacing: layoutMetrics.adaptive(8)) {
            // Back arrow (return to main; test is complete, no confirmation needed)
            HStack {
                AdaptiveIconButton.backButton(action: {
                    HapticManager.shared.lightImpact()
                    onBackToMainMenu()
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
                // Left: title + result message
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

                // Right: mascot (flipped variant)
                MascotView(autoPlayInterval: nil)
                    .frame(width: mascotSize, height: mascotSize)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Body and Footer (same logic as SpacedRepetitionQuestionCard: scroll + gradient overlay, then footer)
private extension TestResultsView {
    var resultsBodyView: some View {
        ScrollView {
            VStack(spacing: layoutMetrics.adaptive(LayoutMetrics.sectionSpacing)) {
                VStack(spacing: layoutMetrics.adaptive(16)) {
                    // Section 1: High-level results (time, requirement, your score, accuracy)
                    SectionContainer(spacing: layoutMetrics.adaptive(12)) {
                        VStack(alignment: .leading, spacing: layoutMetrics.adaptive(12)) {
                            Text("test_results_your_results".localized)
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
                                Text("test_results_correct_answers_label".localized.withTrailingColon)
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
                    // Section 2: Breakdown by category
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
                .padding(.bottom, layoutMetrics.adaptive(100))
            }
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

    var resultsFooterView: some View {
        VStack(spacing: layoutMetrics.adaptive(LayoutMetrics.footerSectionSpacing)) {
            QuizActionButton(
                "try_again".localized,
                style: tryAgainButtonStyle
            ) {
                HapticManager.shared.lightImpact()
                onStartTestLoading?()
                showingRetryCountdown = true
            }
        }
        .padding(.horizontal, layoutMetrics.adaptive(LayoutMetrics.footerHorizontalPadding))
        .padding(.top, layoutMetrics.adaptive(12))
        .background(Color(.systemBackground))
    }
}

// MARK: - Previews (same mock as DEBUG developer menu when available)
#if DEBUG
#Preview("Test Results – Passed") {
    TestResultsView(
        viewModel: DebugTestResultsHelper.makeMockResultsViewModel(passed: true),
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
        viewModel: DebugTestResultsHelper.makeMockResultsViewModel(passed: false),
        onBackToMainMenu: {},
        onTryAgain: {}
    )
    .environmentObject(LanguageManager())
    .environmentObject(FavoritesManager.shared)
    .environment(AppRouter())
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
#endif
