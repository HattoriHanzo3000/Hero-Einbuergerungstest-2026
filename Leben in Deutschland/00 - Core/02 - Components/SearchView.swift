//
//  SearchView.swift
//  Leben in Deutschland
//
//  Search bar with results list. Used by SearchTabView.
//

import SwiftUI

// MARK: - Search View
struct SearchView: View {
    @Binding var searchText: String
    let searchResults: [(question: QuestionModel, subcategory: String, categoryName: String, matchedByTranslation: Bool)]
    var showsSearchField: Bool = true

    @FocusState private var isSearchFocused: Bool
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    
    private var trimmedQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(spacing: 0) {
            if showsSearchField {
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
            }

            if trimmedQuery.isEmpty {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if searchResults.isEmpty {
                ContentUnavailableView.search(text: trimmedQuery)
            } else {
                List {
                    Text(
                        String(
                            format: "search_results_count".localized,
                            searchResults.count,
                            Pluralization.localizedSearchResultsWord(
                                for: searchResults.count,
                                languageCode: languageManager.currentAppLanguage
                            )
                        )
                    )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowSeparator(.hidden, edges: .top)
                        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                        .accessibilityAddTraits(.isHeader)

                    ForEach(searchResults, id: \.question.id) { result in
                        let canStudyTopic = TopicAccessPolicy.isFreeCategory(
                            categoryName: result.categoryName,
                            categories: ContentService.shared.categories
                        ) || subscriptionManager.effectiveIsPro
                        if canStudyTopic {
                            NavigationLink(value: SearchLearningTarget(
                                question: result.question,
                                subcategory: result.subcategory,
                                categoryName: result.categoryName,
                                matchedByTranslation: result.matchedByTranslation
                            )) {
                                SearchQuestionCard(
                                    question: result.question,
                                    subcategoryName: result.subcategory,
                                    categoryName: result.categoryName,
                                    matchedByTranslation: result.matchedByTranslation
                                )
                                .environmentObject(languageManager)
                            }
                            .buttonStyle(.plain)
                            .listRowSeparator(.visible)
                            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                        } else {
                            Button {
                                HapticManager.shared.lightImpact()
                                subscriptionManager.presentProLimitSheet(
                                    titleKey: "limit_topic_pro_title",
                                    messageKey: "limit_topic_pro_message",
                                    accentColorName: "AppCaribean"
                                )
                            } label: {
                                SearchQuestionCard(
                                    question: result.question,
                                    subcategoryName: result.subcategory,
                                    categoryName: result.categoryName,
                                    matchedByTranslation: result.matchedByTranslation
                                )
                                .environmentObject(languageManager)
                            }
                            .buttonStyle(.plain)
                            .listRowSeparator(.visible)
                            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                        }
                    }
                }
                .listStyle(.plain)
                .contentMargins(.horizontal, 0, for: .scrollContent)
                .contentMargins(.top, showsSearchField ? 8 : 0, for: .scrollContent)
                .contentMargins(.bottom, 24, for: .scrollContent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
