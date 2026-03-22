//
//  SearchView.swift
//  Leben in Deutschland
//
//  Search bar with results list. Used by SearchTabView.
//

import SwiftUI

// MARK: - Search navigation target (value-based, avoids deprecated NavigationLink)
private struct SearchLearningTarget: Identifiable, Hashable {
    let id: String
    let subcategory: SubcategoryModel

    init(subcategory: SubcategoryModel) {
        self.subcategory = subcategory
        let qid = subcategory.questions.first?.id ?? ""
        self.id = "\(subcategory.id)-\(qid)"
    }
}

// MARK: - Search View
struct SearchView: View {
    @Binding var searchText: String
    let searchResults: [(question: QuestionModel, subcategory: String, categoryName: String, matchedByTranslation: Bool)]

    @FocusState private var isSearchFocused: Bool
    @EnvironmentObject var languageManager: LanguageManager
    @State private var learningTarget: SearchLearningTarget?

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                TextField("search".localized, text: $searchText)
                    .focused($isSearchFocused)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .font(.body)
                    .foregroundColor(.primary)

                if !searchText.isEmpty {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(.systemGray6).opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                    )
            )
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .onChange(of: isSearchFocused) { oldValue, newValue in
                if newValue {
                    HapticManager.shared.lightImpact()
                }
            }
            .onAppear {
                isSearchFocused = true
            }

            if !searchText.isEmpty {
                if !searchResults.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(searchResults, id: \.question.id) { result in
                                SearchQuestionCard(
                                    question: result.question,
                                    subcategoryName: result.subcategory,
                                    categoryName: result.categoryName,
                                    matchedByTranslation: result.matchedByTranslation,
                                    onNavigateToLearning: {
                                        learningTarget = SearchLearningTarget(subcategory: SubcategoryModel(
                                            name: result.subcategory,
                                            categoryName: result.categoryName,
                                            questions: [result.question]
                                        ))
                                    }
                                )
                                .environmentObject(languageManager)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                    }
                } else {
                    VStack(spacing: 16) {
                        Spacer()

                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)

                        Text("no_search_results".localized)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        Spacer()
                    }
                }
            } else {
                Spacer()
            }
        }
        .navigationDestination(item: $learningTarget) { target in
            LearningView(subcategory: target.subcategory, usesRouterNavigation: false)
                .environmentObject(languageManager)
        }
    }
}
