//
//  TestSessionView.swift
//  Leben in Deutschland
//
//  Main test session view with timer, questions, and navigation
//

import SwiftUI
import UIKit

struct TestSessionView: View {
    @StateObject private var viewModel = TestSessionViewModel()
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var favoritesManager: FavoritesManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var stateManager: StateManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutMetrics) private var layoutMetrics
    @Environment(AppRouter.self) private var router
    
    @State private var showingResults = false
    @State private var showingLevelUp: EagleStage? = nil
    @State private var showingConfirmation = false
    @State private var showingTimerPopup = false
    @State private var isLoading = true
    
    private let contentService = ContentService.shared
    
    @State private var zoomedAsset: ZoomedAsset?
    
    var body: some View {
        Group {
            if viewModel.currentQuestion != nil {
                TestSessionQuestionCard(
                    viewModel: viewModel,
                    showingConfirmation: $showingConfirmation,
                    showingTimerPopup: $showingTimerPopup,
                    zoomedAsset: $zoomedAsset,
                    onFinish: {
                        viewModel.finishTest()
                        let readiness = SpacedRepetitionManager.shared.readinessPercentage(totalQuestions: LayoutMetrics.totalFederalQuestions)
                        if let stage = EagleLevelUpService.checkForLevelUp(newReadinessPercentage: readiness) {
                            showingLevelUp = stage
                        } else {
                            showingResults = true
                        }
                    },
                    onDismiss: {
                        // Pop twice to skip countdown and return to Home
                        router.pop()
                        router.pop()
                    }
                )
                .environmentObject(languageManager)
                .environmentObject(favoritesManager)
                .environmentObject(subscriptionManager)
            } else if isLoading {
                // Loading screen
                VStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("AppBlueLagoon")))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
        }
        .id(languageManager.currentAppLanguage)
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .hidesTabBar()
        .tabBarHidden(true) // Force hide using UIKit for reliability
        .onAppear {
            initializeTest()
        }
        .onDisappear {
            viewModel.stopTimer()
            // Restore tab bar when leaving test session
            restoreTabBar()
        }
        .fullScreenCover(item: $showingLevelUp) { stage in
            EagleLevelUpView(
                stage: stage,
                readinessPercentage: SpacedRepetitionManager.shared.readinessPercentage(totalQuestions: LayoutMetrics.totalFederalQuestions),
                onDismiss: {
                    showingLevelUp = nil
                    showingResults = true
                }
            )
            .environmentObject(languageManager)
            .environment(\.layoutMetrics, layoutMetrics)
        }
        .fullScreenCover(isPresented: $showingResults) {
            TestResultsView(
                viewModel: viewModel,
                onBackToMainMenu: {
                    showingResults = false
                    // Pop to root to return to HomeView
                    router.popToRoot()
                },
                onTryAgain: {
                    // Dismiss results and restart test (countdown was already shown from TestResultsView)
                    showingResults = false
                    // Test should already be loading from onStartTestLoading callback
                    // Just ensure loading state is set
                    if !isLoading {
                        isLoading = true
                    }
                },
                onStartTestLoading: {
                    // Start loading test immediately when Try Again is pressed (during countdown)
                    isLoading = true
                    initializeTest()
                }
            )
                .environmentObject(languageManager)
                .environmentObject(favoritesManager)
                .environmentObject(subscriptionManager)
                .environment(router)
                .interactiveDismissDisabled(true)
        }
        .alert(
            "quit_test_title".localized,
            isPresented: $showingConfirmation,
            actions: {
                Button("cancel".localized, role: .cancel) {
                                HapticManager.shared.lightImpact()
                }
                Button("quit_test".localized, role: .destructive) {
                                HapticManager.shared.heavyImpact()
                                // Save partial test answers before quitting
                                viewModel.finishTest()
                                // Pop twice to skip countdown and return to Home
                                router.pop()
                                router.pop()
                }
            },
            message: {
                Text("quit_test_message".localized)
            }
        )
        .onChange(of: viewModel.remainingTime) { _, remainingTime in
            // Auto-finish only if time runs out (regardless of whether all questions are answered)
            if remainingTime <= 0 && viewModel.finishTime == nil {
                viewModel.finishTest()
                showingResults = true
            }
        }
    }
    
    
    // MARK: - Helper Functions
    
    private func restoreTabBar() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let tabBarController = UITabBarController.find(in: window.rootViewController) {
                tabBarController.tabBar.isHidden = false
            }
        }
    }
    
    func initializeTest() {
        Task {
            // Test simulation always loads German content
            let testLanguage = "de"
            
            // Always reload content in German for test simulation
            await contentService.loadContent(for: testLanguage)
            await HintService.shared.loadHints(for: testLanguage)
            
            // Wait for loading to complete
            while contentService.isLoading {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
            }
            
            let federalQuestions = contentService.getTestFederalQuestions(language: testLanguage)
            var stateQuestions = contentService.getTestStateQuestions(for: stateManager.selectedState, language: testLanguage)
            
            // Limit regional questions to 10
            if stateQuestions.count > 10 {
                stateQuestions = Array(stateQuestions.prefix(10))
            }
            
            if federalQuestions.isEmpty && stateQuestions.isEmpty {
                // Fallback: create test questions
                let testQuestions = createTestQuestions()
                viewModel.initializeTest(generalQuestions: testQuestions, regionalQuestions: [])
            } else if stateQuestions.isEmpty {
                // If no regional questions, use 33 federal ones
                let additionalFederalQuestions = Array(federalQuestions.shuffled().prefix(33))
                viewModel.initializeTest(generalQuestions: additionalFederalQuestions, regionalQuestions: [])
            } else {
                viewModel.initializeTest(generalQuestions: federalQuestions, regionalQuestions: stateQuestions)
            }
            
            isLoading = false
        }
    }
    
    func createTestQuestions() -> [TestQuestion] {
        [
            TestQuestion(
                id: 1,
                originalId: "test_1",
                text: "Was ist die Hauptstadt von Deutschland?",
                options: ["Berlin", "München", "Hamburg", "Köln"],
                correctIndex: 0,
                isRegional: false,
                category: "Staat"
            )
        ]
    }
}

// MARK: - Preview
#Preview("Test Session View") {
    TestSessionView()
        .environmentObject(LanguageManager())
        .environmentObject(FavoritesManager.shared)
        .environmentObject(StateManager.shared)
        .environment(AppRouter())
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

