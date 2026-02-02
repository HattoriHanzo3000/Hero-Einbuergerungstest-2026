//
//  HintService.swift
//  Leben in Deutschland
//
//  Service to load hints from JSON files (one file per language)
//

import Foundation
import Combine

// MARK: - Hint Model
struct HintModel: Codable {
    let questionId: String
    let hint: String
}

// MARK: - Hints Data
struct HintsData: Codable {
    let hints: [HintModel]
}

// MARK: - Hint Service
@MainActor
class HintService: ObservableObject {
    @Published var hints: [String: String] = [:] // question-id -> hint text
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Singleton
    static let shared = HintService()
    
    private init() {}
    
    // MARK: - Load Hints
    
    /// Load hints for specific language
    func loadHints(for language: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let hintsData = try await loadHintsFile(for: language)
            
            // Convert to dictionary for quick lookup
            var hintsDict: [String: String] = [:]
            for hint in hintsData.hints {
                hintsDict[hint.questionId] = hint.hint
            }
            
            hints = hintsDict
            isLoading = false
            print("✅ Loaded \(hintsDict.count) hints for language: \(language)")
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            print("⚠️ Failed to load hints: \(error.localizedDescription)")
        }
    }
    
    /// Get hint for a specific question ID
    func getHint(for questionId: String) -> String? {
        return hints[questionId]
    }
    
    // MARK: - Private Methods
    
    private func loadHintsFile(for language: String) async throws -> HintsData {
        let fileName = "hints_\(language)"
        
        // Try with subdirectory first, then without
        var url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "Content")
        if url == nil {
            url = Bundle.main.url(forResource: fileName, withExtension: "json")
        }
        
        guard let fileURL = url else {
            throw HintError.fileNotFound(fileName)
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        let hintsData = try decoder.decode(HintsData.self, from: data)
        
        return hintsData
    }
}

// MARK: - Hint Errors
enum HintError: LocalizedError {
    case fileNotFound(String)
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let fileName):
            return "Hint file not found: \(fileName).json"
        case .decodingError(let message):
            return "Failed to decode hints: \(message)"
        }
    }
}

