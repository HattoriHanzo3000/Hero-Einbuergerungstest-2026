//
//  HintService.swift
//  Leben in Deutschland
//
//  Service to load hints from content files (hint field on each question)
//

import Foundation
import Combine

// MARK: - Hint Service
@MainActor
class HintService: ObservableObject {
    @Published var hints: [String: String] = [:] // question-id -> hint text (app language)
    @Published var translationHints: [String: String] = [:] // question-id -> hint text (translation language)
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    /// Feature flag to globally enable/disable the hints feature without touching UI code.
    /// Set to `true` when you want hints to be available again.
    private let isHintsFeatureEnabled = false
    
    private var currentTranslationLanguage: String?
    
    private let contentService = ContentService.shared
    
    // MARK: - Singleton
    static let shared = HintService()
    
    private init() {}
    
    // MARK: - Load Hints
    
    /// Load hints from content for the current app language.
    /// ContentService.loadContent(for:) must be called first.
    func loadHints(for language: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let questions = contentService.getAllQuestions()
        hints = buildHintsDict(from: questions)
    }
    
    /// Load translation hints for a specific language.
    /// Ensures translation content is loaded, then builds hints from translated questions.
    func loadTranslationHints(for language: String) async {
        guard currentTranslationLanguage != language else { return }
        
        await contentService.loadTranslationContent(for: language)
        let questions = contentService.getAllTranslatedQuestions()
        translationHints = buildHintsDict(from: questions)
        currentTranslationLanguage = language
    }
    
    /// Get hint for a specific question ID
    /// Supports both formats: "001" and "q001"
    func getHint(for questionId: String) -> String? {
        guard isHintsFeatureEnabled else { return nil }
        if let hint = hints[questionId] { return hint }
        if let hint = hints["q\(questionId)"] { return hint }
        if questionId.hasPrefix("q"), let hint = hints[String(questionId.dropFirst())] { return hint }
        return nil
    }
    
    /// Get hint in translation language for a specific question ID
    func getTranslationHint(for questionId: String) -> String? {
        guard isHintsFeatureEnabled else { return nil }
        if let hint = translationHints[questionId] { return hint }
        if let hint = translationHints["q\(questionId)"] { return hint }
        if questionId.hasPrefix("q"), let hint = translationHints[String(questionId.dropFirst())] { return hint }
        return nil
    }
    
    /// Clear translation cache (e.g., when languages change)
    func clearTranslationCache() {
        translationHints = [:]
        currentTranslationLanguage = nil
    }
    
    // MARK: - Private
    
    private func buildHintsDict(from questions: [QuestionModel]) -> [String: String] {
        var dict: [String: String] = [:]
        for q in questions {
            guard let text = q.hint?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !text.isEmpty else { continue }
            dict[q.id] = text
            dict["q\(q.id)"] = text
        }
        return dict
    }
}
