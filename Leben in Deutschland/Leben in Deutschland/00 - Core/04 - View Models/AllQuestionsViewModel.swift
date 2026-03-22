//
//  AllQuestionsViewModel.swift
//  Leben in Deutschland
//
//  ViewModel for the All Questions reading mode (310 questions: 300 General + 10 from selected state).
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AllQuestionsViewModel: ObservableObject {
    @Published private(set) var questions: [QuestionModel] = []
    @Published var currentIndex: Int = 0
    @Published var showTranslation = false
    @Published private(set) var isLoading = true

    private let contentService = ContentService.shared
    private let favoritesManager = FavoritesManager.shared
    private let stateManager: StateManager

    init(stateManager: StateManager) {
        self.stateManager = stateManager
        self.currentIndex = Self.loadSavedIndex()
    }

    private static func loadSavedIndex() -> Int {
        let saved = UserDefaults.standard.integer(forKey: UserDefaultsKeys.allQuestionsCurrentIndex)
        return max(0, saved)
    }

    /// Persists current question index so the user returns to the same position.
    func saveCurrentPosition() {
        UserDefaults.standard.set(currentIndex, forKey: UserDefaultsKeys.allQuestionsCurrentIndex)
    }

    func loadQuestions(language: String, translationLanguage: String? = nil, selectedState: String? = nil) async {
        isLoading = true
        defer { isLoading = false }

        await contentService.loadContent(for: language)
        await HintService.shared.loadHints(for: language)
        if let translation = translationLanguage, translation != language {
            await HintService.shared.loadTranslationHints(for: translation)
        }

        let resolvedState = selectedState ?? stateManager.selectedState
        var loaded = contentService.getQuestionsForSpacedRepetition(selectedState: resolvedState)
        loaded.sort { sortOrder(for: $0.id) < sortOrder(for: $1.id) }
        questions = loaded
        // Restore saved position, clamped to valid range
        currentIndex = min(currentIndex, max(0, questions.count - 1))
    }

    /// Sort key for chronological order: federal 001–300 first, then state 301–310.
    private func sortOrder(for questionId: String) -> (Int, String) {
        let components = questionId.split(separator: " ")
        let numericPart = String(components.first ?? "")
        let num = Int(numericPart) ?? 0
        let statePart = components.count > 1 ? String(components[1]) : ""
        return (num, statePart)
    }

    func toggleTranslation() {
        showTranslation.toggle()
    }

    func isFavorite(questionId: String) -> Bool {
        favoritesManager.isFavorite(questionId)
    }

    @discardableResult
    func toggleFavorite(for questionId: String, isPremium: Bool) -> Bool {
        let ok = favoritesManager.toggleFavorite(for: questionId, isPremium: isPremium)
        if ok { objectWillChange.send() }
        return ok
    }

    func goToQuestion(at index: Int) {
        guard index >= 0, index < questions.count else { return }
        currentIndex = index
        saveCurrentPosition()
    }
}
