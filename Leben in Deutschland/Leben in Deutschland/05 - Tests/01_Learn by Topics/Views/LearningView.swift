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
    private let usesRouterNavigation: Bool
    
    @StateObject private var viewModel: LearningViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(AppRouter.self) private var router
    @Environment(\.dismiss) private var dismiss
    // Press states removed to avoid gesture conflicts with Button taps
    
    init(subcategory: SubcategoryModel, usesRouterNavigation: Bool = true) {
        self.subcategory = subcategory
        self.usesRouterNavigation = usesRouterNavigation
        self._viewModel = StateObject(wrappedValue: LearningViewModel(subcategory: subcategory))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title, progress, and actions
            headerView
            
            // Question and answers content
            if !viewModel.questions.isEmpty {
                questionContentView
                    .padding(.top, 8)
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
        VStack(alignment: .leading, spacing: 12) {
                HStack {
        AdaptiveIconButton.backButton {
                    if usesRouterNavigation {
                        router.pop()
                    } else {
                        dismiss()
                    }
                    }
                    Spacer()
                }

                Text(subcategory.name)
                .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundColor(Color(.systemGray6))
                .multilineTextAlignment(.leading)
                    .lineLimit(2)
                .minimumScaleFactor(0.85)

            // Row 2: Progress bar
            ProgressView(value: Double(viewModel.answeredCount), total: Double(viewModel.questions.count))
                .progressViewStyle(LinearProgressViewStyle(tint: Color(.systemGray6)))
                .frame(height: 8)
                .clipShape(Capsule())

            // Row 3: Question ID + Actions
            HStack(spacing: 4) {
                if let currentQuestion = viewModel.currentQuestion {
                    Text("question_label".localized + " \(currentQuestion.id)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .foregroundColor(Color(.systemGray6))
                }
                Spacer()
                Button(action: {
                    HapticManager.shared.lightImpact()
                    viewModel.resetCurrentQuestion()
                }) { circleIconButton(icon: "arrow.counterclockwise") }
                Button(action: {
                    HapticManager.shared.lightImpact()
                    viewModel.toggleTranslation()
                }) { circleIconButton(icon: "globe", tint: viewModel.showTranslation ? .orange : Color.accentColor) }
                Button(action: {
                    HapticManager.shared.lightImpact()
                    // TODO: Implement favorites
                }) { circleIconButton(icon: "heart.fill") }
            }
        }
        .padding(.vertical, MainScreenConstants.adaptiveValue(18))
        .padding(.horizontal, MainScreenConstants.adaptiveValue(20))
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.accentColor)
        )
        .padding(.horizontal)
        .padding(.top, 8)
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
                ActionIconButton.reset {
                    viewModel.resetCurrentQuestion()
                }
                
                // Translate button
                ActionIconButton.translation(isActive: viewModel.showTranslation) {
                    viewModel.toggleTranslation()
                }
                
                // Favorite button (placeholder for now)
                ActionIconButton.favorite {
                    // TODO: Implement favorites
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
                .padding(.top, 8)
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
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text("back".localized)
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(viewModel.hasPrevious ? Color.accentColor : .gray)
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
                            .font(.headline)
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.right")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(viewModel.hasNext ? Color.accentColor : .gray)
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
                    .font(.headline)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(viewModel.canCheck ? Color(.systemGray6) : .gray)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canCheck ? Color.accentColor : Color.gray.opacity(0.3))
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
                                        .font(.footnote)
                                        .fontWeight(.semibold)
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

// MARK: - Circular Icon Button (matches island header buttons)
private extension LearningView {
    func circleIconButton(icon: String, tint: Color = Color.accentColor) -> some View {
        ZStack {
            Circle()
                .fill(Color("MainButton"))
                .frame(width: 30, height: 30)
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(tint)
        }
        .frame(width: 44, height: 44)
        .contentShape(Circle())
    }
}

// MARK: - Preview

#Preview("Learning – Basic Law") {
    LearningViewPreview.basicLawPreview()
}

#if DEBUG
@MainActor
private enum LearningViewPreview {
    static func basicLawPreview() -> some View {
        let subcategory = loadBasicLawSubcategory()
        populateCorrectAnswers()
        return LearningPreviewHost(subcategory: subcategory)
    }
    
    private static func loadBasicLawSubcategory() -> SubcategoryModel {
        guard
            let url = Bundle.main.url(forResource: "content_en", withExtension: "json", subdirectory: "Content"),
            let data = try? Data(contentsOf: url),
            let contentArray = try? JSONDecoder().decode([ContentData].self, from: data),
            let content = contentArray.first
        else {
            return fallbackSubcategory()
        }
        
        if let match = content.content.first(where: { $0.category == "Law and Constitution" && $0.subcategory == "Basic Law" }) {
            return SubcategoryModel(
                name: match.subcategory,
                categoryName: match.category,
                questions: Array(match.questions.prefix(10))
            )
        }
        
        return fallbackSubcategory()
    }
    
    private static func populateCorrectAnswers() {
        guard
            let url = Bundle.main.url(forResource: "answers", withExtension: "json", subdirectory: "Content"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode([AnswerData].self, from: data)
        else {
            return
        }
        
        ContentService.shared.correctAnswers = Dictionary(uniqueKeysWithValues: decoded.map { ($0.questionId, $0.answerIndex) })
    }
    
    private static func fallbackSubcategory() -> SubcategoryModel {
        let sampleQuestions: [QuestionModel] = [
            QuestionModel(
                id: "Sample-001",
                text: "Which institution is responsible for protecting the Basic Law in Germany?",
                options: [
                    "The Federal Constitutional Court",
                    "The Federal Council",
                    "The Federal Chancellor",
                    "The Bundestag"
                ],
                category: "Law and Constitution",
                subcategory: "Basic Law"
            ),
            QuestionModel(
                id: "Sample-002",
                text: "What is the first article of the German Basic Law about?",
                options: [
                    "Freedom of speech",
                    "Human dignity",
                    "Freedom of assembly",
                    "Right to asylum"
                ],
                category: "Law and Constitution",
                subcategory: "Basic Law"
            )
        ]
        
        return SubcategoryModel(
            name: "Basic Law",
            categoryName: "Law and Constitution",
            questions: sampleQuestions
        )
    }
}
#endif

@MainActor
private struct LearningPreviewHost: View {
    let subcategory: SubcategoryModel
    @State private var router = AppRouter()
    @StateObject private var languageManager = LanguageManager()
    
    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            LearningView(subcategory: subcategory, usesRouterNavigation: false)
                .environment(router)
                .environmentObject(languageManager)
        }
    }
}

