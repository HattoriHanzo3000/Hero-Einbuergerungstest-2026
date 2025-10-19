//
//  LearningView.swift
//  Leben in Deutschland
//
//  Learning mode view for studying questions by topic
//

import SwiftUI

// MARK: - Learning View
struct LearningView: View {
    let subcategory: SubcategoryModel
    
    @StateObject private var viewModel: LearningViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(AppRouter.self) private var router
    
    init(subcategory: SubcategoryModel) {
        self.subcategory = subcategory
        self._viewModel = StateObject(wrappedValue: LearningViewModel(subcategory: subcategory))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title, progress, and actions
            headerView
            
            // Question and answers content
            if !viewModel.questions.isEmpty {
                questionContentView
            }
            
            Spacer()
            
            // Footer with navigation and check button
            footerView
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadInitialState()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 0) {
            // Title block with back arrow
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let sidePadding = screenWidth * 0.05
                
                ZStack {
                    // Back button
                    HStack {
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            router.pop()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGray6))
                        }
                        .padding(.leading, sidePadding)
                        
                        Spacer()
                    }
                    
                    // Centered title
                    Text(subcategory.name)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color(.systemGray6))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .padding(.horizontal, sidePadding + 44)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: UIScreen.main.bounds.height * 0.06)
            
            // Progress bar
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let sidePadding = screenWidth * 0.05
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    ProgressView(value: Double(viewModel.answeredCount), total: Double(viewModel.questions.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(.systemGray6)))
                        .frame(maxWidth: .infinity)
                        .frame(height: 8)
                        .padding(.horizontal, sidePadding)
                        .padding(.bottom, 10)
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.02)
            
            // Action buttons
            actionButtonsView
        }
        .background(
            RoundedRectangle(cornerRadius: 0, style: .continuous)
                .fill(Color("Fill"))
                .clipShape(
                    RoundedCorner(radius: 35, corners: [.bottomLeft, .bottomRight])
                )
                .ignoresSafeArea(.all, edges: .top)
        )
    }
    
    // MARK: - Action Buttons
    private var actionButtonsView: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let sidePadding = screenWidth * 0.05
            
            HStack(spacing: 10) {
                // Question ID
                if let currentQuestion = viewModel.currentQuestion {
                    Text("question_label".localized + " \(currentQuestion.id)")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(.systemGray6))
                        .padding(.leading, sidePadding)
                }
                
                Spacer()
                
                // Reset button
                Button(action: {
                    HapticManager.shared.lightImpact()
                    viewModel.resetCurrentQuestion()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color(.systemGray6))
                }
                
                // Translate button
                Button(action: {
                    HapticManager.shared.lightImpact()
                    viewModel.toggleTranslation()
                }) {
                    Image(systemName: "globe")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(viewModel.showTranslation ? .orange : Color(.systemGray6))
                }
                
                // Favorite button (placeholder for now)
                Button(action: {
                    HapticManager.shared.lightImpact()
                    // TODO: Implement favorites
                }) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color(.systemGray6))
                }
                .padding(.trailing, sidePadding)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(height: UIScreen.main.bounds.height * 0.08)
    }
    
    // MARK: - Question Content
    private var questionContentView: some View {
        ScrollView {
            if let question = viewModel.currentQuestion {
                QuestionCard(
                    question: question,
                    selectedAnswer: viewModel.selectedAnswer,
                    showCorrectAnswer: viewModel.showCorrectAnswer,
                    showTranslation: viewModel.showTranslation,
                    onAnswerSelected: { index in
                        viewModel.selectAnswer(index)
                    }
                )
                .padding(.horizontal, 16)
                .padding(.top, 24)
            }
        }
    }
    
    // MARK: - Footer View
    private var footerView: some View {
        VStack(spacing: 12) {
            // Back and Next buttons
            HStack(spacing: 16) {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    viewModel.previousQuestion()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                        Text("back".localized)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(viewModel.hasPrevious ? Color("Fill") : .gray)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                }
                .disabled(!viewModel.hasPrevious)
                
                Spacer()
                
                Button(action: {
                    HapticManager.shared.lightImpact()
                    viewModel.nextQuestion()
                }) {
                    HStack(spacing: 4) {
                        Text("next".localized)
                            .font(.system(size: 18, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(viewModel.hasNext ? Color("Fill") : .gray)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                }
                .disabled(!viewModel.hasNext)
            }
            .padding(.horizontal)
            
            // Check button
            Button(action: {
                HapticManager.shared.lightImpact()
                viewModel.checkAnswer()
            }) {
                Text("check_answer_button".localized)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(viewModel.canCheck ? Color(.systemGray6) : .gray)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canCheck ? Color("Fill") : Color.gray.opacity(0.3))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .disabled(!viewModel.canCheck)
            
            // Question navigation bar
            if viewModel.questions.count > 1 {
                questionNavigationBar
            }
        }
        .padding(.bottom, 8)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Question Navigation Bar
    private var questionNavigationBar: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<viewModel.questions.count, id: \.self) { index in
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            viewModel.goToQuestion(at: index)
                        }) {
                            Circle()
                                .fill(circleColor(for: index))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text("\(index + 1)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(circleTextColor(for: index))
                                )
                        }
                        .id(index)
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 44)
            .onChange(of: viewModel.currentIndex) { _, newIndex in
                withAnimation {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func circleColor(for index: Int) -> Color {
        if index == viewModel.currentIndex {
            return Color("SelectedCircle")
        } else if viewModel.isCorrect(at: index) {
            return Color("CorrectCircle")
        } else if viewModel.isIncorrect(at: index) {
            return Color("WrongCircle")
        } else {
            return Color(.systemGray5)
        }
    }
    
    private func circleTextColor(for index: Int) -> Color {
        if index == viewModel.currentIndex {
            return Color(.systemGray6)
        } else if viewModel.isCorrect(at: index) || viewModel.isIncorrect(at: index) {
            return Color(.systemGray6)
        } else {
            return .primary
        }
    }
}

