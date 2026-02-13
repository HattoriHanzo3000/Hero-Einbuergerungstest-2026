//
//  CategoryModel.swift
//  Leben in Deutschland
//
//  Category data model
//

import Foundation

// MARK: - Category Model
struct CategoryModel: Identifiable, Hashable {
    /// Stable id for SwiftUI identity; category names are unique in content.
    var id: String { name }
    let name: String
    let subcategories: [SubcategoryModel]
    
    var totalQuestions: Int {
        subcategories.reduce(0) { $0 + $1.questionCount }
    }
}

