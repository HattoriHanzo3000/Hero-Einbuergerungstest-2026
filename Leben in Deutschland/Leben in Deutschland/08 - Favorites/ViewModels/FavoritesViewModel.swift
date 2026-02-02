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
    
    func loadFavorites(language: String) async {
        // Ensure content is loaded
        await contentService.loadContent(for: language)
        await HintService.shared.loadHints(for: language)
        
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
        
        // Load saved answers for favorited questions
        for question in favoriteQuestions {
            if let savedAnswer = answersService.getAnswer(for: question.id) {
                selectedAnswers[question.id] = savedAnswer
                showCorrectAnswers[question.id] = true
            }
        }
    }
    
    func selectAnswer(_ index: Int, for questionId: String) {
        guard !(showCorrectAnswers[questionId] ?? false) else { return }
        HapticManager.shared.lightImpact()
        selectedAnswers[questionId] = index
    }
    
    func checkAnswer(for questionId: String) {
        guard let answer = selectedAnswers[questionId] else { return }
        
        // Save answer
        answersService.saveAnswer(answer, for: questionId)
        showCorrectAnswers[questionId] = true
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
}

