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
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var favoritesManager: FavoritesManager
    
    @State private var showingAnswers = false
    
    private var results: TestResults {
        TestResults(
            correctAnswers: viewModel.correctCount,
            totalQuestions: viewModel.questions.count,
            isPassed: viewModel.isPassed,
            timeUsed: viewModel.timeUsed,
            answers: viewModel.answers
        )
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Result
                VStack(spacing: 16) {
                    Image(systemName: results.isPassed ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(results.isPassed ? .green : .red)
                    
                    Text(results.isPassed ? "test_passed".localized : "test_failed".localized)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(results.isPassed ? .green : .red)
                    
                    Text("\(results.correctAnswers) \("of".localized) \(results.totalQuestions) \("questions_correct".localized)")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding()
            
                // Statistics
                VStack(spacing: 12) {
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
                            .foregroundColor(results.isPassed ? .green : .red)
                    }
                    
                    HStack {
                        Text("accuracy".localized)
                        Spacer()
                        Text("\(Int(results.accuracy * 100))%")
                            .foregroundColor(results.isPassed ? .green : .red)
                    }
                }
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            
                Spacer()
            
                // Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        showingAnswers = true
                    }) {
                        Text("view_answers".localized)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color(.systemGray6))
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(Color("ProgressOrange"))
                    .cornerRadius(12)
                    
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        onBackToMainMenu()
                    }) {
                        Text("back_to_main_menu".localized)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color(.systemGray6))
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(Color("AppPrimary"))
                    .cornerRadius(12)
                }
                .padding()
            }
        }
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
    }
}

