//
//  ContentService.swift
//  Leben in Deutschland
//
//  Service to load and manage question content from JSON files
//

import Foundation
import Combine

// MARK: - Content Service
@MainActor
class ContentService: ObservableObject {
    @Published var categories: [CategoryModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var correctAnswers: [String: Int] = [:]
    
    private var allQuestions: [QuestionModel] = []
    
    // MARK: - Singleton
    static let shared = ContentService()
    
    private init() {}
    
    // MARK: - Load Content
    
    /// Load questions for specific language
    func loadContent(for language: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Load correct answers first
            try await loadCorrectAnswers()
            
            // Load questions for language
            let content = try await loadContentFile(for: language)
            
            // Group by category and subcategory
            let groupedCategories = groupByCategory(content.content)
            
            // Update published properties on main thread
            categories = groupedCategories
            isLoading = false
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    // MARK: - Private Methods
    
    private func loadContentFile(for language: String) async throws -> ContentData {
        let fileName = "content_\(language)"
        
        // Try with subdirectory first, then without
        var url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "Content")
        if url == nil {
            url = Bundle.main.url(forResource: fileName, withExtension: "json")
        }
        
        guard let fileURL = url else {
            throw ContentError.fileNotFound(fileName)
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        
        // The JSON file is an array with one ContentData object
        let contentArray = try decoder.decode([ContentData].self, from: data)
        
        guard let content = contentArray.first else {
            throw ContentError.decodingError("Content array is empty")
        }
        
        return content
    }
    
    private func loadCorrectAnswers() async throws {
        // Try with subdirectory first, then without
        var url = Bundle.main.url(forResource: "answers", withExtension: "json", subdirectory: "Content")
        if url == nil {
            url = Bundle.main.url(forResource: "answers", withExtension: "json")
        }
        
        guard let fileURL = url else {
            throw ContentError.fileNotFound("answers")
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        let answers = try decoder.decode([AnswerData].self, from: data)
        
        // Convert to dictionary
        correctAnswers = Dictionary(uniqueKeysWithValues: answers.map { ($0.questionId, $0.answerIndex) })
    }
    
    private func groupByCategory(_ categoryData: [CategoryData]) -> [CategoryModel] {
        // Preserve order from JSON file, not alphabetical
        var categoryMap: [String: [CategoryData]] = [:]
        var categoryOrder: [String] = []
        
        // Group by category name while preserving order
        for data in categoryData {
            if categoryMap[data.category] == nil {
                categoryOrder.append(data.category)
                categoryMap[data.category] = []
            }
            categoryMap[data.category]?.append(data)
        }
        
        // Create CategoryModel array in original order
        return categoryOrder.map { categoryName in
            let subcategoryData = categoryMap[categoryName] ?? []
            let subcategories = subcategoryData.map { data in
                SubcategoryModel(
                    name: data.subcategory,
                    categoryName: categoryName,
                    questions: data.questions
                )
            }
            
            return CategoryModel(
                name: categoryName,
                subcategories: subcategories
            )
        }
    }
    
    // MARK: - Helper Methods
    
    /// Get all questions for a specific subcategory
    func getQuestions(for subcategory: SubcategoryModel) -> [QuestionModel] {
        return subcategory.questions
    }
    
    /// Get all questions
    func getAllQuestions() -> [QuestionModel] {
        return categories.flatMap { category in
            category.subcategories.flatMap { $0.questions }
        }
    }
    
    // MARK: - Translation Support
    
    /// Get a question in a specific language by ID
    func getQuestion(id: String, in language: String) async -> QuestionModel? {
        do {
            let content = try await loadContentFile(for: language)
            
            // Search through all categories and subcategories
            for categoryData in content.content {
                if let question = categoryData.questions.first(where: { $0.id == id }) {
                    return question
                }
            }
            
            return nil
        } catch {
            print("Error loading question for translation: \(error)")
            return nil
        }
    }
    
    // MARK: - Find Subcategory
    
    /// Find a subcategory by name within a category
    func findSubcategory(named subcategoryName: String, in categoryName: String, language: String) -> SubcategoryModel? {
        // Search in current categories first
        for category in categories where category.name == categoryName {
            if let subcategory = category.subcategories.first(where: { $0.name == subcategoryName }) {
                return subcategory
            }
        }
        
        // If not found and categories are empty, return nil
        // The view will need to handle loading
        return nil
    }
}

// MARK: - Content Error
enum ContentError: LocalizedError {
    case fileNotFound(String)
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let fileName):
            return "Could not find file: \(fileName).json"
        case .decodingError(let message):
            return "Failed to decode content: \(message)"
        }
    }
}

