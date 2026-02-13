//
//  CategoriesStateService.swift
//  Leben in Deutschland
//
//  Service for persisting Categories view state
//

import Foundation

class CategoriesStateService {
    static let shared = CategoriesStateService()

    private init() {}
    
    // MARK: - Expanded Categories
    
    /// Save expanded category names (using names as stable identifiers)
    func saveExpandedCategories(_ categoryNames: Set<String>) {
        let namesArray = Array(categoryNames)
        UserDefaults.standard.set(namesArray, forKey: UserDefaultsKeys.categoriesExpanded)
    }

    /// Load expanded category names
    func loadExpandedCategories() -> Set<String> {
        guard let namesArray = UserDefaults.standard.array(forKey: UserDefaultsKeys.categoriesExpanded) as? [String] else {
            return []
        }
        return Set(namesArray)
    }
    
    /// Clear expanded categories
    func clearExpandedCategories() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.categoriesExpanded)
    }

    // MARK: - Clear All State
    
    /// Clear all Categories view state
    func clearAllState() {
        clearExpandedCategories()
    }
}
