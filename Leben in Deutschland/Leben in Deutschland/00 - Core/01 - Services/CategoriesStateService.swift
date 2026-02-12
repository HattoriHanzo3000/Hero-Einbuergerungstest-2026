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

    // MARK: - Scroll Position

    /// Save scroll position (top or bottom)
    func saveScrollPosition(isAtBottom: Bool) {
        UserDefaults.standard.set(isAtBottom, forKey: UserDefaultsKeys.categoriesScrollPosition)
    }

    /// Load scroll position
    func loadScrollPosition() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKeys.categoriesScrollPosition)
    }

    /// Clear scroll position
    func clearScrollPosition() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.categoriesScrollPosition)
    }
    
    // MARK: - Clear All State
    
    /// Clear all Categories view state
    func clearAllState() {
        clearExpandedCategories()
        clearScrollPosition()
    }
}
