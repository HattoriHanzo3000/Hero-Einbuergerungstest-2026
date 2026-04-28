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
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @StateObject private var viewModel = CategoriesViewModel()
    @State private var searchText = ""
    @State private var isSearchPresented = true
    @FocusState private var isSearchFieldFocused: Bool
    @State private var router = AppRouter()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                SearchView(
                    searchText: $searchText,
                    searchResults: viewModel.searchResults(for: searchText),
                    showsSearchField: false
                )
                .environmentObject(languageManager)
                .environmentObject(subscriptionManager)
            }
            .navigationTitle("tab_search_title".localized(for: languageManager.currentAppLanguage))
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $searchText,
                isPresented: $isSearchPresented,
                placement: .automatic,
                prompt: Text("search".localized)
            )
            .searchFocused($isSearchFieldFocused)
            .onAppear {
                scheduleSearchFieldFocus()
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

    private func scheduleSearchFieldFocus() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 120_000_000)
            isSearchFieldFocused = true
        }
    }
}

// MARK: - Preview
#Preview {
    SearchTabView()
        .environmentObject(LanguageManager())
}
