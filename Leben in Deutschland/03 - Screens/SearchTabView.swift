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

    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @StateObject private var viewModel = CategoriesViewModel()
    @State private var searchText = ""
    @State private var isSearchPresented = true
    @FocusState private var isSearchFieldFocused: Bool
    @State private var navigationPath = NavigationPath()
    @State private var router = AppRouter()
    
    private var searchTabIsSelected: Bool {
        selectedTab == .search
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
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
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text("search".localized)
            )
            .searchFocused($isSearchFieldFocused)
            .onAppear {
                isSearchPresented = true
                scheduleSearchFieldFocus()
            }
            .onChange(of: isSearchPresented) { _, presented in
                guard !presented, selectedTab == .search else { return }
                guard scenePhase == .active else { return }
                searchText = ""
                isSearchFieldFocused = false
                selectedTab = sectionBeforeSearch
            }
            .onChange(of: searchTabIsSelected) { _, isSelected in
                if isSelected {
                    isSearchPresented = true
                    scheduleSearchFieldFocus()
                } else {
                    isSearchPresented = true
                }
            }
            .onChange(of: navigationPath.count) { _, depth in
                guard depth == 0, selectedTab == .search else { return }
                isSearchPresented = true
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
    SearchTabView(
        selectedTab: .constant(.search),
        sectionBeforeSearch: .learn
    )
        .environmentObject(LanguageManager())
}
