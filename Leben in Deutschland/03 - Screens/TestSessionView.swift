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
    @State private var showingTimerPopup = false
    @State private var showingQuitConfirmation = false
    @State private var isLoading = true
    
    private let contentService = ContentService.shared
    
    @State private var zoomedAsset: ZoomedAsset?
    
    var body: some View {
        Group {
            if viewModel.currentQuestion != nil {
                TestSessionQuestionCard(
                    viewModel: viewModel,
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
                    onDismiss: quitTest
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
        .navigationTitle("test_simulation_title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationInteractivePopDisabled()
        .hidesLearningChrome()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    HapticManager.shared.lightImpact()
                    showingQuitConfirmation = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                .tint(.primary)
                .accessibilityLabel("close".localized)
            }
        }
        .alert("quit_test_title".localized, isPresented: $showingQuitConfirmation) {
            Button("quit_test".localized, role: .destructive) {
                HapticManager.shared.lightImpact()
                quitTest()
            }
            Button("cancel".localized, role: .cancel) {
                HapticManager.shared.lightImpact()
            }
        } message: {
            Text("quit_test_message".localized)
        }
        .onAppear {
            initializeTest()
        }
        .onDisappear {
            viewModel.stopTimer()
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
        .onChange(of: viewModel.remainingTime) { _, remainingTime in
            // Auto-finish only if time runs out (regardless of whether all questions are answered)
            if remainingTime <= 0 && viewModel.finishTime == nil {
                viewModel.finishTest()
                showingResults = true
            }
        }
    }
    
    
    // MARK: - Helper Functions

    private func quitTest() {
        viewModel.stopTimer()
        router.pop()
        router.pop()
    }

    func initializeTest() {
        Task {
            let testLanguage = ContentService.testSimulationLanguageCode
            
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

