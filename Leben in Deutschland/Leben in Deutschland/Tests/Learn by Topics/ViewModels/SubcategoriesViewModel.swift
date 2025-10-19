//
//  SubcategoriesViewModel.swift
//  Leben in Deutschland
//
//  ViewModel for Subcategories screen
//

import Foundation
import SwiftUI
import Combine

// MARK: - Subcategories ViewModel
@MainActor
class SubcategoriesViewModel: ObservableObject {
    @Published var subcategories: [SubcategoryModel] = []
    
    private let category: CategoryModel
    private let contentService: ContentService
    
    // MARK: - Initialization
    
    init(category: CategoryModel) {
        self.category = category
        self.contentService = ContentService.shared
        self.subcategories = category.subcategories
    }
    
    // MARK: - Public Methods
    
    /// Get questions for a subcategory
    func getQuestions(for subcategory: SubcategoryModel) -> [QuestionModel] {
        return contentService.getQuestions(for: subcategory)
    }
}

