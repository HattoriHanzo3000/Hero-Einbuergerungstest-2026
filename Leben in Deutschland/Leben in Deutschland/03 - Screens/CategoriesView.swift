//
//  CategoriesView.swift
//  Leben in Deutschland
//
//  Main view for displaying all categories
//

import SwiftUI

// MARK: - Categories View
struct CategoriesView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject private var premiumManager: PremiumManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutMetrics) private var layoutMetrics

    @StateObject private var viewModel = CategoriesViewModel()
    @ObservedObject private var answersService = AnswersService.shared
    @State private var expandedCategoryNames: Set<String> = []
    private let stateService = CategoriesStateService.shared
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                CategoriesTabHeaderCard(
                    onBackTapped: { dismiss() },
                    onPremiumTap: { premiumManager.presentPaywall() },
                    useCard: false
                )
                .padding(.horizontal, layoutMetrics.adaptive(16))
                .padding(.bottom, layoutMetrics.adaptive(12))
                .background(
                    Rectangle()
                        .fill(LiquidGlassGradient.blue.screenBackground)
                        .ignoresSafeArea(edges: .top)
                )
                .overlay(RoundedRectangle(cornerRadius: 0).stroke(Color.orange, lineWidth: 1))

                Divider()
                
                // Content area with system white background
                ZStack {
                    Color(.systemBackground)
                        .ignoresSafeArea(edges: .bottom)
                    
                    if viewModel.isLoading || viewModel.categories.isEmpty && viewModel.errorMessage == nil {
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle())
                            .tint(Color.accentColor)
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            
                            Text(errorMessage)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    } else {
                        // Show normal category view
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(viewModel.categories) { category in
                                    ExpandableCategoryView(
                                        category: category,
                                        isExpanded: expandedCategoryNames.contains(category.name),
                                        onToggle: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                if expandedCategoryNames.contains(category.name) {
                                                    expandedCategoryNames.remove(category.name)
                                                } else {
                                                    expandedCategoryNames.insert(category.name)
                                                }
                                            }
                                            stateService.saveExpandedCategories(expandedCategoryNames)
                                            HapticManager.shared.lightImpact()
                                        },
                                        answersService: answersService
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
                            .padding(.bottom, 32)
                        }
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .id(languageManager.currentAppLanguage)
        .navigationBarHidden(true)
        .task {
            await viewModel.loadCategories(
                for: languageManager.currentAppLanguage,
                translationLanguage: languageManager.currentTranslationLanguage
            )
        }
        .task(id: "\(languageManager.currentAppLanguage)-\(languageManager.currentTranslationLanguage)") {
            // Load translation content when languages change
            let translationLanguage = languageManager.currentTranslationLanguage
            if translationLanguage != languageManager.currentAppLanguage {
                await ContentService.shared.loadTranslationContent(for: translationLanguage)
            } else {
                ContentService.shared.clearTranslationCache()
            }
        }
        .onAppear {
            expandedCategoryNames = stateService.loadExpandedCategories()
        }
        .onDisappear {
            stateService.saveExpandedCategories(expandedCategoryNames)
        }
        .tabBarHidden(false)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var router = AppRouter()

    NavigationStack(path: $router.navigationPath) {
        CategoriesView()
            .environmentObject(LanguageManager())
            .environmentObject(PremiumManager.shared)
            .environment(router)
            .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
    }
}
