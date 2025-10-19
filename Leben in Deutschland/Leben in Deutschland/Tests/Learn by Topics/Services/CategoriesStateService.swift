//
//  CategoriesStateService.swift
//  Leben in Deutschland
//
//  Service for persisting Categories view state
//

import Foundation

class CategoriesStateService {
    static let shared = CategoriesStateService()
    
    private let expandedCategoriesKey = "categories_expanded_categories"
    private let scrollPositionKey = "categories_scroll_position"
    
    private init() {}
    
    // MARK: - Expanded Categories
    
    /// Save expanded category names (using names as stable identifiers)
    func saveExpandedCategories(_ categoryNames: Set<String>) {
        let namesArray = Array(categoryNames)
        UserDefaults.standard.set(namesArray, forKey: expandedCategoriesKey)
    }
    
    /// Load expanded category names
    func loadExpandedCategories() -> Set<String> {
        guard let namesArray = UserDefaults.standard.array(forKey: expandedCategoriesKey) as? [String] else {
            return []
        }
        return Set(namesArray)
    }
    
    /// Clear expanded categories
    func clearExpandedCategories() {
        UserDefaults.standard.removeObject(forKey: expandedCategoriesKey)
    }
    
    // MARK: - Scroll Position
    
    /// Save scroll position (top or bottom)
    func saveScrollPosition(isAtBottom: Bool) {
        UserDefaults.standard.set(isAtBottom, forKey: scrollPositionKey)
    }
    
    /// Load scroll position
    func loadScrollPosition() -> Bool {
        return UserDefaults.standard.bool(forKey: scrollPositionKey)
    }
    
    /// Clear scroll position
    func clearScrollPosition() {
        UserDefaults.standard.removeObject(forKey: scrollPositionKey)
    }
    
    // MARK: - Clear All State
    
    /// Clear all Categories view state
    func clearAllState() {
        clearExpandedCategories()
        clearScrollPosition()
    }
}
