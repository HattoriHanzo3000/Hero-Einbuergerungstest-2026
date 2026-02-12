//
//  SubcategoriesView.swift
//  Leben in Deutschland
//
//  View for displaying subcategories of a selected category
//

import SwiftUI

// MARK: - Subcategories View
struct SubcategoriesView: View {
    let category: CategoryModel
    
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: SubcategoriesViewModel
    @State private var selectedSubcategory: SubcategoryModel?
    @State private var showQuiz = false
    
    // MARK: - Initialization
    
    init(category: CategoryModel) {
        self.category = category
        _viewModel = StateObject(wrappedValue: SubcategoriesViewModel(category: category))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with category name
            VStack(spacing: 0) {
                // Close button row
                HStack {
                    Spacer()
                    
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
                    }
                    .padding(.trailing, 24)
                    .padding(.top, 20)
                }
                
                // Title
                Text(category.name)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
            .background(Color(.systemBackground))
            
            Divider()
            
            // Subcategories list
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.subcategories) { subcategory in
                        SubcategoryCard(subcategory: subcategory) {
                            selectedSubcategory = subcategory
                            showQuiz = true
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showQuiz) {
            if let subcategory = selectedSubcategory {
                // TODO: Navigate to QuizView
                NavigationView {
                    VStack {
                        Text("Quiz View")
                            .font(.title)
                        Text(subcategory.name)
                            .font(.headline)
                        Text("\(subcategory.questionCount) questions")
                            .font(.subheadline)
                        
                        Button("Close") {
                            showQuiz = false
                        }
                        .padding()
                    }
                    .navigationTitle("Quiz")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SubcategoriesView(
        category: CategoryModel(
            name: "Law and Constitution",
            subcategories: [
                SubcategoryModel(
                    name: "Basic Law",
                    categoryName: "Law and Constitution",
                    questions: []
                ),
                SubcategoryModel(
                    name: "Basic Rights",
                    categoryName: "Law and Constitution",
                    questions: []
                )
            ]
        )
    )
    .environmentObject(LanguageManager())
}

