//
//  FavoritesViewModel.swift
//  Leben in Deutschland
//
//  ViewModel for managing favorites view state
//

import Foundation
import SwiftUI
import Combine

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favoriteQuestions: [QuestionModel] = []
    @Published var currentIndex: Int = 0
    @Published var selectedAnswers: [String: Int] = [:]
    @Published var showCorrectAnswers: [String: Bool] = [:]
    @Published var showTranslation: Bool = false
    
    private let favoritesManager = FavoritesManager.shared
    private let contentService = ContentService.shared
    private let answersService = AnswersService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private var languageManager: LanguageManager?
    
    init() {
        // Observe favorites changes to reload questions
        favoritesManager.$favoriteQuestionIds
            .dropFirst() // Skip initial value
            .sink { [weak self] _ in
                Task { @MainActor in
                    guard let self = self, let languageManager = self.languageManager else { return }
                    await self.loadFavorites(language: languageManager.currentAppLanguage)
                }
            }
            .store(in: &cancellables)
    }
    
    func setLanguageManager(_ manager: LanguageManager) {
        languageManager = manager
    }
    
    func loadFavorites(language: String, translationLanguage: String? = nil) async {
        // Ensure content is loaded
        await contentService.loadContent(for: language)
        await HintService.shared.loadHints(for: language)
        if let translation = translationLanguage, translation != language {
            await HintService.shared.loadTranslationHints(for: translation)
        }
        
        // Get all favorite question IDs
        let favoriteIds = favoritesManager.favoriteQuestionIds
        
        // Load questions from ContentService
        var questions: [QuestionModel] = []
        for category in contentService.categories {
            for subcategory in category.subcategories {
                for question in subcategory.questions {
                    if favoriteIds.contains(question.id) {
                        questions.append(question)
                    }
                }
            }
        }
        
        // Sort by question ID to maintain consistent order
        favoriteQuestions = questions.sorted { $0.id < $1.id }
        
        // Favorites is read-only - don't load saved answers, always show correct answer
    }
    
    func selectAnswer(_ index: Int, for questionId: String) {
        // Read-only mode: answer selection disabled
    }
    
    func checkAnswer(for questionId: String) {
        guard let answer = selectedAnswers[questionId] else { return }
        
        // Save answer
        answersService.saveAnswer(answer, for: questionId)
        showCorrectAnswers[questionId] = true
    }
    
    func resetCurrentQuestion(for questionId: String) {
        answersService.clearAnswer(for: questionId)
        selectedAnswers[questionId] = nil
        showCorrectAnswers[questionId] = false
    }
    
    func toggleTranslation() {
        showTranslation.toggle()
    }
    
    func isFavorite(questionId: String) -> Bool {
        favoritesManager.isFavorite(questionId)
    }
    
    func toggleFavorite(for questionId: String) {
        favoritesManager.toggleFavorite(for: questionId)
        // Questions will reload automatically via Combine subscription
    }
    
    func isCorrect(at index: Int) -> Bool {
        guard index < favoriteQuestions.count else { return false }
        let questionId = favoriteQuestions[index].id
        guard showCorrectAnswers[questionId] == true,
              let selected = selectedAnswers[questionId],
              let correctIndex = contentService.correctAnswers[questionId] else {
            return false
        }
        return selected == correctIndex
    }
    
    func isIncorrect(at index: Int) -> Bool {
        guard index < favoriteQuestions.count else { return false }
        let questionId = favoriteQuestions[index].id
        guard showCorrectAnswers[questionId] == true,
              let selected = selectedAnswers[questionId],
              let correctIndex = contentService.correctAnswers[questionId] else {
            return false
        }
        return selected != correctIndex
    }
}

