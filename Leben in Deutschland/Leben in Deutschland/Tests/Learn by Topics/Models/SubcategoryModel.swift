//
//  SubcategoryModel.swift
//  Leben in Deutschland
//
//  Subcategory data model
//

import Foundation

// MARK: - Subcategory Model
struct SubcategoryModel: Identifiable, Hashable {
    let id: UUID = UUID()
    let name: String
    let categoryName: String
    let questions: [QuestionModel]
    
    var questionCount: Int {
        questions.count
    }
    
    // Completion percentage based on answered questions
    // For now returns 0, will be calculated from user progress later
    var completionPercentage: Double {
        // TODO: Calculate from user progress manager
        return 0.0
    }
    
    var answeredCount: Int {
        // TODO: Get from user progress manager
        return 0
    }
}

