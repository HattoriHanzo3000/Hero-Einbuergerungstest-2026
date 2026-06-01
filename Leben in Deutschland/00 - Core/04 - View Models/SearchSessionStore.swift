//
//  SearchSessionStore.swift
//  Leben in Deutschland
//
//  Persists search query and navigation across tab switches and TabView remounts.
//

import Combine
import SwiftUI

// MARK: - Search Session Store
@MainActor
final class SearchSessionStore: ObservableObject {
    @Published var searchText = ""
    @Published var navigationPath = NavigationPath()
    @Published var isSearchPresented = true

    let categoriesViewModel = CategoriesViewModel()

    /// Clears search when the user dismisses search and returns to the previous tab.
    func clearAfterDismiss() {
        searchText = ""
        navigationPath = NavigationPath()
        isSearchPresented = false
    }
}
