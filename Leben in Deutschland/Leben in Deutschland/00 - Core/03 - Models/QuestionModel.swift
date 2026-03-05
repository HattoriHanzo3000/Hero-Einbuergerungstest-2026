//
//  QuestionModel.swift
//  Leben in Deutschland
//
//  Question data model for Learn by Topics
//

import Foundation

// MARK: - Question Model
struct QuestionModel: Codable, Identifiable, Hashable {
    let id: String
    let text: String
    let options: [String]
    var hint: String?
    var category: String?
    var subcategory: String?
    
    // Check if answer is correct
    func isCorrect(_ answerIndex: Int, correctAnswers: [String: Int]) -> Bool {
        guard let correctIndex = correctAnswers[id] else { return false }
        return answerIndex == correctIndex
    }
}

// MARK: - Category Data Structure (for JSON parsing)
struct CategoryData: Codable {
    let category: String
    let subcategory: String
    let questions: [QuestionModel]
}

// MARK: - Content Data Structure (for JSON parsing)
struct ContentData: Codable {
    let language: String
    let content: [CategoryData]
}

// MARK: - Answer Data Structure (for JSON parsing)
struct AnswerData: Codable {
    let questionId: String
    let answerIndex: Int
    
    enum CodingKeys: String, CodingKey {
        case questionId = "question-id"
        case answerIndex = "answer-index"
    }
}

