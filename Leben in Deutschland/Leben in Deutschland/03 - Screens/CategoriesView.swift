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
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutMetrics) private var layoutMetrics

    @StateObject private var viewModel = CategoriesViewModel()
    @ObservedObject private var answersService = AnswersService.shared
    @State private var expandedCategoryNames: Set<String> = []

    @AppStorage(UserDefaultsKeys.learnByTopicsDisclaimerDismissed) private var disclaimerDismissed = false
    @State private var showDisclaimer = false
    @State private var doNotShowAgain = false

    private let stateService = CategoriesStateService.shared
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                CategoriesTabHeaderCard(
                    onBackTapped: { dismiss() },
                    isProUser: subscriptionManager.effectiveIsPremium,
                    useCard: false
                )
                .padding(.horizontal, layoutMetrics.adaptive(16))
                .padding(.bottom, layoutMetrics.adaptive(12))
                .background(
                    Rectangle()
                        .fill(LiquidGlassGradient.blue.screenBackground)
                        .ignoresSafeArea(edges: .top)
                )

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
                                        isFreeTopicBlock: viewModel.categories.first?.name == category.name,
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
            if !disclaimerDismissed, !viewModel.isLoading, !viewModel.categories.isEmpty {
                showDisclaimer = true
            }
        }
        .onChange(of: viewModel.categories.isEmpty) { _, isEmpty in
            if !isEmpty, !disclaimerDismissed, !viewModel.isLoading, !showDisclaimer {
                showDisclaimer = true
            }
        }
        .onDisappear {
            stateService.saveExpandedCategories(expandedCategoryNames)
        }
        .sheet(isPresented: $showDisclaimer) {
            LearnModeDisclaimerSheet(
                titleKey: "learn_by_topics_disclaimer_title",
                messageKey: "learn_by_topics_disclaimer_message",
                accentColor: Color("AppCaribean"),
                doNotShowAgain: $doNotShowAgain,
                onDismiss: {
                    if doNotShowAgain {
                        disclaimerDismissed = true
                    }
                    showDisclaimer = false
                }
            )
            .environmentObject(languageManager)
            .environment(\.layoutMetrics, layoutMetrics)
        }
        .hidesTabBar()
        .tabBarHidden(true)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var router = AppRouter()

    NavigationStack(path: $router.navigationPath) {
        CategoriesView()
            .environmentObject(LanguageManager())
            .environmentObject(SubscriptionManager.shared)
            .environment(router)
            .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
    }
}
