//
//  CategoryModel.swift
//  Leben in Deutschland
//
//  Category data model
//

import Foundation

// MARK: - Category Model
struct CategoryModel: Identifiable, Hashable {
    let id: UUID = UUID()
    let name: String
    let subcategories: [SubcategoryModel]
    
    var totalQuestions: Int {
        subcategories.reduce(0) { $0 + $1.questionCount }
    }
    
    var completionPercentage: Double {
        let total = subcategories.reduce(0.0) { $0 + Double($1.questionCount) }
        let completed = subcategories.reduce(0.0) { $0 + ($1.completionPercentage * Double($1.questionCount)) }
        return total > 0 ? completed / total : 0.0
    }
}

