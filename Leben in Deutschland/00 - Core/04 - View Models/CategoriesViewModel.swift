//
//  CategoriesViewModel.swift
//  Leben in Deutschland
//
//  ViewModel for Categories screen
//

import Foundation
import SwiftUI
import Combine

// MARK: - Categories ViewModel
@MainActor
class CategoriesViewModel: ObservableObject {
    @Published var categories: [CategoryModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let contentService: ContentService

    // MARK: - Initialization
    
    init() {
        self.contentService = ContentService.shared
        
        // Observe content service changes
        contentService.$categories
            .assign(to: &$categories)
        
        contentService.$isLoading
            .assign(to: &$isLoading)
        
        contentService.$errorMessage
            .assign(to: &$errorMessage)
    }
    
    // MARK: - Public Methods
    
    /// Load categories for current language
    func loadCategories(for language: String, translationLanguage: String? = nil) async {
        await contentService.loadContent(for: language)
        await HintService.shared.loadHints(for: language)
        if let translation = translationLanguage, translation != language {
            await HintService.shared.loadTranslationHints(for: translation)
        }
    }

    // MARK: - Search
    
    /// Maximum number of search results to return.
    static let searchResultLimit = 50
    
    /// Search questions across categories in app and translation languages.
    func searchResults(for query: String) -> [(question: QuestionModel, subcategory: String, categoryName: String, matchedByTranslation: Bool)] {
        let trimmed = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        
        var results: [(question: QuestionModel, subcategory: String, categoryName: String, matchedByTranslation: Bool)] = []
        var seenQuestionIds = Set<String>()
        
        for category in categories {
            for subcategory in category.subcategories {
                for question in subcategory.questions {
                    guard !seenQuestionIds.contains(question.id) else { continue }
                    
                    var matches = false
                    var matchedByTranslation = false
                    
                    if question.id.lowercased().contains(trimmed) {
                        matches = true
                    }
                    
                    let matchedInAppLanguage = question.text.lowercased().contains(trimmed) ||
                        question.options.contains { $0.lowercased().contains(trimmed) }
                    if matchedInAppLanguage {
                        matches = true
                    }
                    
                    if let translated = contentService.getTranslatedQuestion(id: question.id) {
                        let matchedInTranslation = translated.text.lowercased().contains(trimmed) ||
                            translated.options.contains { $0.lowercased().contains(trimmed) }
                        if matchedInTranslation {
                            matches = true
                            matchedByTranslation = true
                        }
                    }
                    
                    if matches {
                        results.append((question, subcategory.name, category.name, matchedByTranslation))
                        seenQuestionIds.insert(question.id)
                    }
                }
            }
        }
        
        return Array(results.prefix(Self.searchResultLimit))
    }
}

