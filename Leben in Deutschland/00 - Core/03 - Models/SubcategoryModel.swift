//
//  SubcategoryModel.swift
//  Leben in Deutschland
//
//  Subcategory data model
//

import Foundation

// MARK: - Subcategory Model
struct SubcategoryModel: Identifiable, Hashable {
    /// Stable id for SwiftUI identity; composite of category and subcategory name.
    var id: String { "\(categoryName)-\(name)" }
    let name: String
    let categoryName: String
    let questions: [QuestionModel]
    
    var questionCount: Int {
        questions.count
    }
}

