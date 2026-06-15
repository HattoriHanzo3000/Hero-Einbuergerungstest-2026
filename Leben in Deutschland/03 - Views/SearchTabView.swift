//
//  SearchTabView.swift
//  Leben in Deutschland
//
//  Full-screen search tab. Uses CategoriesViewModel for search across all questions.
//

import SwiftUI

struct SearchLearningTarget: Hashable {
    let question: QuestionModel
    let subcategory: String
    let categoryName: String
    let matchedByTranslation: Bool

    var id: String {
        "\(categoryName)-\(subcategory)-\(question.id)"
    }
}

// MARK: - Search Tab View
struct SearchTabView: View {
    @Binding var selectedTab: MainView.TabIdentifier
    var sectionBeforeSearch: MainView.TabIdentifier
    @ObservedObject var session: SearchSessionStore

    @Environment(\.dismissSearch) private var dismissSearch
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @FocusState private var isSearchFieldFocused: Bool
    @State private var router = AppRouter()
    @State private var isReturningToPreviousTab = false

    private var searchTabIsSelected: Bool {
        selectedTab == .search
    }

    var body: some View {
        NavigationStack(path: $session.navigationPath) {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                SearchView(
                    searchText: $session.searchText,
                    searchResults: session.categoriesViewModel.searchResults(for: session.searchText),
                    showsSearchField: false
                )
                .environmentObject(languageManager)
                .environmentObject(subscriptionManager)
            }
            .navigationTitle("tab_search_title".localized(for: languageManager.currentAppLanguage))
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $session.searchText,
                isPresented: $session.isSearchPresented,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text("search".localized)
            )
            .searchFocused($isSearchFieldFocused)
            .onAppear {
                guard searchTabIsSelected else { return }
                session.isSearchPresented = true
                scheduleSearchFieldFocus()
            }
            .onChange(of: session.isSearchPresented) { _, presented in
                guard !presented, selectedTab == .search else { return }
                guard scenePhase == .active else { return }
                guard !isReturningToPreviousTab else { return }
                returnToSectionBeforeSearch()
            }
            .onChange(of: selectedTab) { _, newTab in
                guard newTab != .search else { return }
                isSearchFieldFocused = false
                restoreTabBarAfterLeavingSearch()
            }
            .onChange(of: searchTabIsSelected) { _, isSelected in
                if isSelected {
                    session.isSearchPresented = true
                    scheduleSearchFieldFocus()
                } else {
                    isSearchFieldFocused = false
                    restoreTabBarAfterLeavingSearch()
                }
            }
            .onChange(of: session.navigationPath.count) { _, depth in
                guard depth == 0, selectedTab == .search else { return }
                session.isSearchPresented = true
                scheduleSearchFieldFocus()
            }
            .navigationDestination(for: SearchLearningTarget.self) { target in
                SearchQuestionDetailView(question: target.question)
                    .environmentObject(languageManager)
                    .environmentObject(subscriptionManager)
            }
        }
        .environment(router)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .id(languageManager.currentAppLanguage)
        .task {
            await session.categoriesViewModel.loadCategories(
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
            guard searchTabIsSelected else { return }
            isSearchFieldFocused = true
        }
    }

    private func returnToSectionBeforeSearch() {
        guard !isReturningToPreviousTab else { return }
        isReturningToPreviousTab = true

        let destination = sectionBeforeSearch
        session.clearAfterDismiss()
        isSearchFieldFocused = false

        dismissSearch()

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000)
            selectedTab = destination
            TabBarVisibility.restoreVisible()
            try? await Task.sleep(nanoseconds: 350_000_000)
            isReturningToPreviousTab = false
            TabBarVisibility.restoreVisible()
        }
    }

    private func restoreTabBarAfterLeavingSearch() {
        TabBarVisibility.restoreVisible()
    }
}

// MARK: - Preview
#Preview {
    SearchTabView(
        selectedTab: .constant(.search),
        sectionBeforeSearch: .learn,
        session: SearchSessionStore()
    )
    .environmentObject(LanguageManager())
}
