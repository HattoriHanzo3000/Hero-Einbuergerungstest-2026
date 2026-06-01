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
    private var questionImages: [String: String] = [:] // question-id -> asset name
    private var translatedQuestionsMap: [String: QuestionModel] = [:] // question-id -> translated question
    private var currentTranslationLanguage: String? = nil
    
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
            
            // Load question images
            try await loadQuestionImages()
            
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
    
    private func loadQuestionImages() async throws {
        // Try with subdirectory first, then without
        var url = Bundle.main.url(forResource: "question_images", withExtension: "json", subdirectory: "Content")
        if url == nil {
            url = Bundle.main.url(forResource: "question_images", withExtension: "json")
        }
        
        guard let fileURL = url else {
            // Question images are optional, so don't throw error
            questionImages = [:]
            return
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        struct QuestionImageData: Codable {
            let questionId: String
            let asset: String
            
            enum CodingKeys: String, CodingKey {
                case questionId = "question-id"
                case asset
            }
        }
        let images = try decoder.decode([QuestionImageData].self, from: data)
        
        // Convert to dictionary
        questionImages = Dictionary(uniqueKeysWithValues: images.map { ($0.questionId, $0.asset) })
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
        
        // Create CategoryModel array in original order, and inject category/subcategory
        // into each QuestionModel so that test/statistics logic can see them.
        return categoryOrder.map { categoryName in
            let subcategoryData = categoryMap[categoryName] ?? []
            let subcategories = subcategoryData.map { data in
                let enrichedQuestions: [QuestionModel] = data.questions.map { question in
                    var q = question
                    q.category = categoryName
                    q.subcategory = data.subcategory
                    return q
                }
                
                return SubcategoryModel(
                    name: data.subcategory,
                    categoryName: categoryName,
                    questions: enrichedQuestions
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
    
    /// Get questions for spaced repetition: federal (310) + regional for selected state (10).
    /// When selectedState is nil, returns only federal questions.
    func getQuestionsForSpacedRepetition(selectedState: String?) -> [QuestionModel] {
        let allQuestions = getAllQuestions()
        let federalQuestions = allQuestions.filter { question in
            let components = question.id.split(separator: " ")
            if components.count == 2, let stateCode = components.last, stateCode.count == 2, stateCode.allSatisfy({ $0.isUppercase }) {
                return false
            }
            return true
        }
        guard let state = selectedState else { return federalQuestions }
        let stateCode = getStateCode(for: state)
        guard !stateCode.isEmpty else { return federalQuestions }
        let stateQuestions = allQuestions.filter { question in
            question.id.contains(" \(stateCode)")
        }
        return federalQuestions + stateQuestions
    }
    
    // MARK: - Translation Support
    
    /// Load translation content for a specific language and cache all questions
    /// This enables fast dual-language search without loading individual questions
    func loadTranslationContent(for language: String) async {
        // Skip if already loaded for this language
        guard currentTranslationLanguage != language else { return }
        
        do {
            let content = try await loadContentFile(for: language)
            
            // Build translation map: question-id -> translated question
            var translationMap: [String: QuestionModel] = [:]
            for categoryData in content.content {
                for question in categoryData.questions {
                    translationMap[question.id] = question
                }
            }
            
            translatedQuestionsMap = translationMap
            currentTranslationLanguage = language
        } catch {
            print("Error loading translation content: \(error)")
            // Clear cache on error
            translatedQuestionsMap = [:]
            currentTranslationLanguage = nil
        }
    }
    
    /// Get a translated question by ID (from cache if available)
    func getTranslatedQuestion(id: String) -> QuestionModel? {
        return translatedQuestionsMap[id]
    }
    
    /// Get all translated questions (for HintService to build translation hints)
    func getAllTranslatedQuestions() -> [QuestionModel] {
        return Array(translatedQuestionsMap.values)
    }
    
    /// Clear translation cache (e.g., when languages change)
    func clearTranslationCache() {
        translatedQuestionsMap = [:]
        currentTranslationLanguage = nil
    }
    
    /// Get a question in a specific language by ID (loads on-demand if not cached)
    func getQuestion(id: String, in language: String) async -> QuestionModel? {
        // Check cache first if it's the translation language
        if language == currentTranslationLanguage, let cached = translatedQuestionsMap[id] {
            return cached
        }
        
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
    
    // MARK: - Test Questions

    /// Test simulation exam language (questions and answers are always German).
    nonisolated static let testSimulationLanguageCode = "de"

    /// Loads questions from a bundled content file without replacing the app's loaded `categories`.
    func questionsSnapshot(for language: String) async throws -> [QuestionModel] {
        try await ensureCorrectAnswersLoaded()
        let content = try await loadContentFile(for: language)
        return content.content.flatMap { categoryData in
            categoryData.questions.map { question in
                var enriched = question
                enriched.category = categoryData.category
                enriched.subcategory = categoryData.subcategory
                return enriched
            }
        }
    }

    /// Federal test question text/options from a language file (e.g. German for test simulation).
    func federalTestQuestion(originalId: String, language: String = testSimulationLanguageCode) async throws -> TestQuestion? {
        let question = try await questionsSnapshot(for: language).first(where: { $0.id == originalId })
        guard let question, Self.isFederalQuestionId(question.id) else { return nil }
        guard let correctIndex = correctAnswers[question.id] else { return nil }
        return TestQuestion(
            id: 0,
            originalId: question.id,
            text: question.text,
            options: question.options,
            correctIndex: correctIndex,
            isRegional: false,
            category: question.category ?? ""
        )
    }

    private func ensureCorrectAnswersLoaded() async throws {
        if !correctAnswers.isEmpty { return }
        try await loadCorrectAnswers()
    }

    private static func isFederalQuestionId(_ id: String) -> Bool {
        let components = id.split(separator: " ")
        if components.count == 2,
           let stateCode = components.last,
           stateCode.count == 2,
           stateCode.allSatisfy(\.isUppercase) {
            return false
        }
        return true
    }
    
    /// Get federal (general) test questions - questions without state codes
    func getTestFederalQuestions(language: String = "de") -> [TestQuestion] {
        let allQuestions = getAllQuestions()
        let federalQuestions = allQuestions.filter { Self.isFederalQuestionId($0.id) }
        
        return federalQuestions.enumerated().compactMap { index, question in
            guard let correctIndex = correctAnswers[question.id] else { return nil }
            return TestQuestion(
                id: index + 1,
                originalId: question.id,
                text: question.text,
                options: question.options,
                correctIndex: correctIndex,
                isRegional: false,
                category: question.category ?? ""
            )
        }
    }
    
    /// Get regional (state-specific) test questions
    func getTestStateQuestions(for state: String?, language: String = "de") -> [TestQuestion] {
        guard let state = state else { return [] }
        
        // Map state name to code
        let stateCode = getStateCode(for: state)
        guard !stateCode.isEmpty else { return [] }
        
        let allQuestions = getAllQuestions()
        let stateQuestions = allQuestions.filter { question in
            // Regional questions have format like "301 BW", "308 BY"
            question.id.contains(" \(stateCode)")
        }
        
        return stateQuestions.enumerated().compactMap { index, question in
            guard let correctIndex = correctAnswers[question.id] else { return nil }
            return TestQuestion(
                id: index + 1000, // Use different range for regional questions
                originalId: question.id,
                text: question.text,
                options: question.options,
                correctIndex: correctIndex,
                isRegional: true,
                category: question.category ?? ""
            )
        }
    }
    
    /// Get illustration asset name for a question ID
    func getIllustrationAsset(for questionId: String) -> String? {
        return questionImages[questionId]
    }
    
    // MARK: - State Code Mapping
    
    private func getStateCode(for stateName: String) -> String {
        let stateMap: [String: String] = [
            "Baden-Württemberg": "BW",
            "Bayern": "BY",
            "Berlin": "BE",
            "Brandenburg": "BB",
            "Bremen": "HB",
            "Hamburg": "HH",
            "Hessen": "HE",
            "Mecklenburg-Vorpommern": "MV",
            "Niedersachsen": "NI",
            "Nordrhein-Westfalen": "NW",
            "Rheinland-Pfalz": "RP",
            "Saarland": "SL",
            "Sachsen": "SN",
            "Sachsen-Anhalt": "ST",
            "Schleswig-Holstein": "SH",
            "Thüringen": "TH"
        ]
        return stateMap[stateName] ?? ""
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

