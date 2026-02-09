//
//  LearningViewModel.swift
//  Leben in Deutschland
//
//  ViewModel for managing learning mode state
//

import Foundation
import SwiftUI
import Combine

@MainActor
class LearningViewModel: ObservableObject {
    @Published var currentIndex: Int = 0
    @Published var selectedAnswer: Int? = nil
    @Published var showCorrectAnswer: Bool = false
    @Published var showTranslation: Bool = false
    
    let subcategory: SubcategoryModel
    let questions: [QuestionModel]
    
    private var answeredQuestions: Set<String> = []
    private var correctlyAnswered: Set<String> = []
    private var incorrectlyAnswered: Set<String> = []
    
    private let answersService = AnswersService.shared
    private let favoritesManager = FavoritesManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(subcategory: SubcategoryModel) {
        self.subcategory = subcategory
        self.questions = subcategory.questions
        
        // Observe favorites changes to update UI
        favoritesManager.$favoriteQuestionIds
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    var currentQuestion: QuestionModel? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    var answeredCount: Int {
        answeredQuestions.count
    }
    
    var hasPrevious: Bool {
        currentIndex > 0
    }
    
    var hasNext: Bool {
        currentIndex < questions.count - 1
    }
    
    var canCheck: Bool {
        selectedAnswer != nil && !showCorrectAnswer
    }
    
    // MARK: - Actions
    
    func loadInitialState() {
        // Load saved position
        currentIndex = loadSavedPosition()
        
        // Load all saved answers for this subcategory's questions
        let correctAnswers = ContentService.shared.correctAnswers
        
        for question in questions {
            if let savedAnswer = answersService.getAnswer(for: question.id) {
                answeredQuestions.insert(question.id)
                
                // Check if saved answer is correct or incorrect
                if let correctIndex = correctAnswers[question.id] {
                    if savedAnswer == correctIndex {
                        correctlyAnswered.insert(question.id)
                    } else {
                        incorrectlyAnswered.insert(question.id)
                    }
                }
            }
        }
        
        // Load saved answer for current question
        if let currentQuestion = currentQuestion {
            selectedAnswer = answersService.getAnswer(for: currentQuestion.id)
            showCorrectAnswer = answeredQuestions.contains(currentQuestion.id)
        }
    }
    
    func selectAnswer(_ index: Int) {
        guard !showCorrectAnswer else { return }
        HapticManager.shared.lightImpact()
        selectedAnswer = index
    }
    
    func checkAnswer() {
        guard let answer = selectedAnswer, let question = currentQuestion else { return }
        
        // Save answer to persistent storage
        answersService.saveAnswer(answer, for: question.id)
        
        // Mark as answered
        answeredQuestions.insert(question.id)
        
        // Check if answer is correct and record to spaced repetition statistics
        let correctAnswers = ContentService.shared.correctAnswers
        if let correctIndex = correctAnswers[question.id] {
            let isCorrect = answer == correctIndex
            // Record answer to spaced repetition for readiness score
            SpacedRepetitionManager.shared.recordAnswer(for: question.id, isCorrect: isCorrect)
            // Intuitive haptics: success for correct, stronger error for wrong
            if isCorrect {
                correctlyAnswered.insert(question.id)
                incorrectlyAnswered.remove(question.id)
                HapticManager.shared.success()
            } else {
                incorrectlyAnswered.insert(question.id)
                correctlyAnswered.remove(question.id)
                HapticManager.shared.errorStrong()
            }
        }
        
        showCorrectAnswer = true
    }
    
    func resetCurrentQuestion() {
        guard let question = currentQuestion else { return }
        
        // Clear answer from persistent storage
        answersService.clearAnswer(for: question.id)
        
        // Record reset as negative for readiness score
        SpacedRepetitionManager.shared.recordReset(for: question.id)
        
        selectedAnswer = nil
        showCorrectAnswer = false
        answeredQuestions.remove(question.id)
        correctlyAnswered.remove(question.id)
        incorrectlyAnswered.remove(question.id)
    }
    
    func toggleTranslation() {
        showTranslation.toggle()
    }
    
    func isFavorite(questionId: String) -> Bool {
        favoritesManager.isFavorite(questionId)
    }
    
    func toggleFavorite(for questionId: String) {
        favoritesManager.toggleFavorite(for: questionId)
        // UI will update automatically via Combine subscription
    }
    
    func previousQuestion() {
        guard hasPrevious else { return }
        
        saveCurrentPosition()
        currentIndex -= 1
        updateStateForNewQuestion()
    }
    
    func nextQuestion() {
        guard hasNext else { return }
        
        saveCurrentPosition()
        currentIndex += 1
        updateStateForNewQuestion()
    }
    
    func goToQuestion(at index: Int) {
        guard index >= 0 && index < questions.count else { return }
        
        saveCurrentPosition()
        currentIndex = index
        updateStateForNewQuestion()
    }
    
    func isAnswered(at index: Int) -> Bool {
        guard index < questions.count else { return false }
        return answeredQuestions.contains(questions[index].id)
    }
    
    func isCorrect(at index: Int) -> Bool {
        guard index < questions.count else { return false }
        return correctlyAnswered.contains(questions[index].id)
    }
    
    func isIncorrect(at index: Int) -> Bool {
        guard index < questions.count else { return false }
        return incorrectlyAnswered.contains(questions[index].id)
    }
    
    // MARK: - Private Helpers
    
    private func updateStateForNewQuestion() {
        guard let question = currentQuestion else { return }
        
        showTranslation = false
        
        // Load saved answer if exists
        selectedAnswer = answersService.getAnswer(for: question.id)
        
        // Check if new question was already answered
        if answeredQuestions.contains(question.id) {
            showCorrectAnswer = true
        } else {
            showCorrectAnswer = false
        }
    }
    
    // MARK: - Position Persistence
    
    private func saveCurrentPosition() {
        let key = "subcategory_position_\(subcategory.name)"
        UserDefaults.standard.set(currentIndex, forKey: key)
    }
    
    private func loadSavedPosition() -> Int {
        let key = "subcategory_position_\(subcategory.name)"
        let savedPosition = UserDefaults.standard.integer(forKey: key)
        return max(0, min(savedPosition, questions.count - 1))
    }
}

