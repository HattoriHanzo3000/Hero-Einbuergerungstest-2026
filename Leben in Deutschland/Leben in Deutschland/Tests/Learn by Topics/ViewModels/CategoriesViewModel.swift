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
    private var cancellables = Set<AnyCancellable>()
    
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
    func loadCategories(for language: String) async {
        await contentService.loadContent(for: language)
    }
    
    /// Get category by name
    func getCategory(by name: String) -> CategoryModel? {
        return categories.first { $0.name == name }
    }
}

