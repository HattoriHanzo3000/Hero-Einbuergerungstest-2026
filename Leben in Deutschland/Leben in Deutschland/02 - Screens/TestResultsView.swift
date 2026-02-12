//
//  TestResultsView.swift
//  Leben in Deutschland
//
//  View showing test results with pass/fail status and statistics
//

import SwiftUI

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
        results.isPassed ? .green : .red
    }
    
    /// View answers: red or green to match result (Test failed / Test passed).
    private var viewAnswersButtonStyle: QuizActionButton.Style {
        QuizActionButton.Style(
            backgroundColor: resultColor,
            disabledBackgroundColor: Color(.systemGray2),
            haloPrimaryColor: resultColor.opacity(0.36),
            haloSecondaryColor: Color.white.opacity(0.18),
            showsHaloWhenDisabled: false,
            suppressGlow: true
        )
    }
    
    /// Try Again: App Orange.
    private var tryAgainButtonStyle: QuizActionButton.Style {
        QuizActionButton.Style(
            backgroundColor: Color("AppOrange"),
            disabledBackgroundColor: Color(.systemGray2),
            haloPrimaryColor: Color("AppOrange").opacity(0.36),
            haloSecondaryColor: Color.white.opacity(0.18),
            showsHaloWhenDisabled: false,
            suppressGlow: true
        )
    }
    
    private var quitButtonStyle: QuizActionButton.Style {
        QuizActionButton.Style(
            backgroundColor: Color("AppBlueLagoon"),
            disabledBackgroundColor: Color(.systemGray2),
            haloPrimaryColor: Color("AppBlueLagoon").opacity(0.36),
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
                ScrollView {
                    VStack(spacing: layoutMetrics.adaptive(24)) {
                        // Header: Mascot + Title
                        HStack(alignment: .center, spacing: layoutMetrics.adaptive(16)) {
                            MascotView(
                                autoPlayInterval: nil
                            )
                            .fixedSize(horizontal: true, vertical: false)
                            
                            VStack(alignment: .leading, spacing: layoutMetrics.adaptive(4)) {
                                Text(results.isPassed ? "test_passed".localized : "test_failed".localized)
                                    .font(.system(.title, design: .rounded).weight(.bold))
                                    .foregroundColor(resultColor)
                                
                                Text("\(results.correctAnswers) \("of".localized) \(results.totalQuestions) \("questions_correct".localized)")
                                    .font(.system(.body, design: .rounded).weight(.semibold))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, layoutMetrics.adaptive(20))
                        .padding(.top, layoutMetrics.adaptive(20))
                    
                        // Statistics Section (matching home section style)
                        SectionContainer(spacing: layoutMetrics.adaptive(12)) {
                            VStack(spacing: layoutMetrics.adaptive(12)) {
                                HStack {
                                    Text("time_used".localized)
                                    Spacer()
                                    Text(results.timeString)
                                }
                                
                                HStack {
                                    Text("minimum_requirement".localized)
                                    Spacer()
                                    Text("17 \("of".localized) 33")
                                }
                                
                                HStack {
                                    Text("your_result".localized)
                                    Spacer()
                                    Text("\(results.correctAnswers) \("of".localized) 33")
                                        .foregroundColor(resultColor)
                                }
                                
                                HStack {
                                    Text("accuracy".localized)
                                    Spacer()
                                    Text("\(Int(results.accuracy * 100))%")
                                        .foregroundColor(resultColor)
                                }
                            }
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                        }
                        .padding(.horizontal, layoutMetrics.adaptive(20))
                        .padding(.bottom, layoutMetrics.adaptive(100)) // Space for bottom buttons
                    }
                }
                
                // Separator above buttons
                Divider()
                    .background(Color(.separator))
                
                // Buttons fixed at bottom
                VStack(spacing: layoutMetrics.adaptive(12)) {
                    QuizActionButton(
                        "view_answers".localized,
                        style: viewAnswersButtonStyle
                    ) {
                        HapticManager.shared.lightImpact()
                        showingAnswers = true
                    }
                    
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
                    
                    QuizActionButton(
                        "quit_the_test".localized,
                        style: quitButtonStyle
                    ) {
                        HapticManager.shared.lightImpact()
                        onBackToMainMenu()
                    }
                }
                .padding(.horizontal, layoutMetrics.adaptive(24))
                .padding(.top, layoutMetrics.adaptive(16))
                .padding(.bottom, layoutMetrics.adaptive(24))
                .background(
                    Color(.systemBackground)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: -4)
                )
            }
        }
        }
        .id(languageManager.currentAppLanguage)
        .fontDesign(.rounded)
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
    }
}

// MARK: - Previews
private func makePreviewResultsViewModel(passed: Bool) -> TestSessionViewModel {
    let sampleQuestions: [TestQuestion] = (0..<3).map { i in
        TestQuestion(
            id: i,
            originalId: "\(100 + i)",
            text: "Sample question \(i + 1) text?",
            options: ["Option A", "Option B", "Option C", "Option D"],
            correctIndex: 0,
            isRegional: false,
            category: "Politics"
        )
    }
    let vm = TestSessionViewModel()
    vm.initializeTest(generalQuestions: sampleQuestions, regionalQuestions: [])
    for i in 0..<vm.questions.count {
        vm.goToQuestion(i)
        let q = vm.questions[i]
        let chosen = passed ? q.correctIndex : (q.correctIndex + 1) % max(1, q.options.count)
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
