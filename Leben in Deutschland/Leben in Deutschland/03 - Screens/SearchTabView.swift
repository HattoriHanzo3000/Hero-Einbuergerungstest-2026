//
//  SearchTabView.swift
//  Leben in Deutschland
//
//  Full-screen search tab. Uses CategoriesViewModel for search across all questions.
//

import SwiftUI

// MARK: - Search Tab View
struct SearchTabView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @StateObject private var viewModel = CategoriesViewModel()
    @State private var searchText = ""
    @State private var router = AppRouter()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                SearchView(
                    searchText: $searchText,
                    searchResults: viewModel.searchResults(for: searchText)
                )
                .environmentObject(languageManager)
            }
        }
        .environment(router)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .id(languageManager.currentAppLanguage)
        .task {
            await viewModel.loadCategories(
                for: languageManager.currentAppLanguage,
                translationLanguage: languageManager.currentTranslationLanguage
            )
        }
        .task(id: "\(languageManager.currentAppLanguage)-\(languageManager.currentTranslationLanguage)") {
            let translationLanguage = languageManager.currentTranslationLanguage
            if translationLanguage != languageManager.currentAppLanguage {
                await ContentService.shared.loadTranslationContent(for: translationLanguage)
            } else {
                ContentService.shared.clearTranslationCache()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SearchTabView()
        .environmentObject(LanguageManager())
}
