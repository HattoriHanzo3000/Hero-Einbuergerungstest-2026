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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.layoutMetrics) private var layoutMetrics
    @Environment(AppRouter.self) private var router
    
    @StateObject private var viewModel = CategoriesViewModel()
    @ObservedObject private var answersService = AnswersService.shared
    @State private var expandedCategoryNames: Set<String> = []
    @State private var searchText = ""
    @State private var isSearchVisible = false
    @FocusState private var isSearchFocused: Bool
    private let stateService = CategoriesStateService.shared
    
    private var controlSize: CGFloat {
        switch dynamicTypeSize {
        case .xSmall, .small, .medium:
            return layoutMetrics.adaptive(36)
        case .large:
            return layoutMetrics.adaptive(38)
        case .xLarge:
            return layoutMetrics.adaptive(40)
        case .xxLarge, .xxxLarge:
            return layoutMetrics.adaptive(42)
        default:
            return layoutMetrics.adaptive(44)
        }
    }
    
    private var headerCardVerticalPadding: CGFloat { layoutMetrics.adaptive(18) }
    private var headerCardHorizontalPadding: CGFloat { layoutMetrics.adaptive(20) }
    private var mascotToContentSpacing: CGFloat { layoutMetrics.adaptive(16) }
    private var mascotSize: CGFloat { layoutMetrics.adaptive(120) }
    private var titleToMessageSpacing: CGFloat { layoutMetrics.adaptive(6) }
    
    private var searchResults: [(question: QuestionModel, subcategory: String, matchedByTranslation: Bool)] {
        viewModel.searchResults(for: searchText)
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (fixed section): header card + divider
                VStack(alignment: .leading, spacing: layoutMetrics.adaptive(6)) {
                    HStack {
                        AdaptiveIconButton.backButton(action: {
                            dismiss()
                        }, tintColor: .white)
                        
                        Spacer()
                        
                        PremiumCrownButton(action: { premiumManager.presentPaywall() }, color: .white)
                        
                        Spacer()
                        
                        AdaptiveIconButton(
                            systemName: isSearchVisible ? "xmark" : "magnifyingglass",
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isSearchVisible.toggle()
                                    if !isSearchVisible {
                                        searchText = ""
                                        isSearchFocused = false
                                    }
                                }
                            },
                            accessibilityLabel: isSearchVisible ? "Close search" : "Search categories",
                            accessibilityHint: "Toggle search mode",
                            tintColor: .white
                        )
                        .animation(.none, value: isSearchVisible)
                    }
                    
                    HStack(alignment: .center, spacing: mascotToContentSpacing) {
                        MascotView(
                            autoPlayInterval: 60
                        )
                        .frame(width: mascotSize, height: mascotSize)
                        
                        VStack(alignment: .leading, spacing: titleToMessageSpacing) {
                            Text("learn_by_topics_header_message".localized)
                                .font(.system(.body, design: .rounded).weight(.medium))
                                .lineSpacing(4)
                                .foregroundColor(.white.opacity(0.92))
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.vertical, headerCardVerticalPadding)
                .padding(.horizontal, headerCardHorizontalPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .background(LiquidGlassBackground(gradient: .blue))
                .clipShape(RoundedRectangle(cornerRadius: layoutMetrics.adaptive(32), style: .continuous))
                .overlay(HeaderBorderOverlay())
                .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
                .padding(.horizontal, layoutMetrics.adaptive(20))
                .padding(.top, layoutMetrics.adaptive(8))
                .padding(.bottom, layoutMetrics.adaptive(12))
                
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
                    } else if isSearchVisible {
                        // Show search bar inside white sheet
                        VStack(spacing: 0) {
                            // Search bar at top
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
                            
                            // Search results or empty state
                            if !searchText.isEmpty {
                                if !searchResults.isEmpty {
                                    ScrollView {
                                        LazyVStack(spacing: 12) {
                                            ForEach(searchResults, id: \.question.id) { result in
                                                SearchQuestionCard(
                                                    question: result.question,
                                                    subcategoryName: result.subcategory,
                                                    matchedByTranslation: result.matchedByTranslation
                                                )
                                                .environmentObject(languageManager)
                                            }
                                        }
                                        .padding(.horizontal, 24)
                                        .padding(.top, 16)
                                        .padding(.bottom, 32)
                                    }
                                } else {
                                    // No search results
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
                                // Blank white space when search bar is empty
                                Spacer()
                            }
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
                            .padding(.top, 4)
                            .padding(.bottom, 32)
                        }
                    }
                }
            }
        }
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
        .onChange(of: isSearchVisible) { oldValue, newValue in
            if newValue {
                // Load translation content when search is activated (if not already loaded)
                Task {
                    let translationLanguage = languageManager.currentTranslationLanguage
                    if translationLanguage != languageManager.currentAppLanguage {
                        await ContentService.shared.loadTranslationContent(for: translationLanguage)
                    }
                }
            }
        }
        .onAppear {
            expandedCategoryNames = stateService.loadExpandedCategories()
        }
        .onDisappear {
            stateService.saveExpandedCategories(expandedCategoryNames)
        }
        .hidesTabBar()
        .tabBarHidden(true)
    }
}

// MARK: - Expandable Category View
private struct ExpandableCategoryView: View {
    let category: CategoryModel
    let isExpanded: Bool
    let onToggle: () -> Void
    @ObservedObject var answersService: AnswersService
    @State private var isPressed = false
    @State private var iconWiggle: Double = 0
    @State private var wiggleTrigger = 0
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    // Check if all subcategories are completed
    private var isCategoryCompleted: Bool {
        category.subcategories.allSatisfy { subcategory in
            answersService.getCompletionPercentage(for: subcategory) >= 1.0
        }
    }
    
    private var categoryIcon: String {
        CategoryIconMapping.icon(for: category.name)
    }
    
    private var iconContainerSize: CGFloat {
        switch dynamicTypeSize {
        case .xSmall, .small, .medium:
            return 60
        case .large:
            return 66
        case .xLarge:
            return 72
        case .xxLarge, .xxxLarge:
            return 80
        default:
            return 88
        }
    }
    
    private var textContainerMinHeight: CGFloat {
        iconContainerSize
    }
    
    private var containerPadding: CGFloat {
        switch dynamicTypeSize {
        case .xSmall, .small, .medium:
            return 16
        case .large:
            return 18
        case .xLarge:
            return 20
        default:
            return 22
        }
    }
    
    private var categoryGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppCaribean").opacity(0.72),
                Color("AppCaribean").opacity(0.52)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var categoryBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppCaribean").opacity(0.14),
                Color("AppCaribean").opacity(0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func runWiggleAnimation() {
        let duration: Double = 0.07
        withAnimation(.easeInOut(duration: duration)) { iconWiggle = -8 }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.easeInOut(duration: duration)) { iconWiggle = 8 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration * 2) {
            withAnimation(.easeInOut(duration: duration)) { iconWiggle = -4 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration * 3) {
            withAnimation(.easeInOut(duration: duration)) { iconWiggle = 0 }
        }
    }
    
    @ViewBuilder
    private var categoryIconView: some View {
        let image = Image(systemName: categoryIcon)
            .font(.system(.title, design: .rounded).weight(.semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        if #available(iOS 18.0, *) {
            image
                .symbolEffect(.wiggle.byLayer, options: .default, value: wiggleTrigger)
                .onChange(of: isExpanded) { _, newValue in
                    if newValue { wiggleTrigger += 1 }
                }
        } else {
            image
                .rotationEffect(.degrees(iconWiggle))
                .onChange(of: isExpanded) { _, newValue in
                    if newValue {
                        runWiggleAnimation()
                    } else {
                        withAnimation(.easeOut(duration: 0.1)) { iconWiggle = 0 }
                    }
                }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                HapticManager.shared.lightImpact()
                onToggle()
            }) {
                VStack(alignment: .leading, spacing: 12) {
                        categoryIconView
                        
                    HStack(spacing: 12) {
                            Text(category.name)
                            .font(.title3.weight(.semibold))
                                .fontDesign(.rounded)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if isCategoryCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white.opacity(0.9))
                                    .accessibilityLabel("Category completed")
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        }
                    }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, containerPadding)
                .padding(.horizontal, containerPadding)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(categoryGradient)
                )
            }
            .contentShape(Rectangle())
            .buttonStyle(.plain)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .buttonPressAnimation(isPressed: $isPressed)
            
            // Subcategories (expandable - inside the same card)
            if isExpanded {
                VStack(spacing: 12) {
                                    ForEach(category.subcategories) { subcategory in
                                        SubcategoryButton(
                                            subcategory: subcategory,
                                            answersService: answersService
                                        )
                                    }
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(categoryBackgroundGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.45), Color.white.opacity(0.12)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.6
                )
        )
        }
    }

// MARK: - Subcategory Button
private struct SubcategoryButton: View {
    let subcategory: SubcategoryModel
    @ObservedObject var answersService: AnswersService
    @Environment(AppRouter.self) private var router
    @State private var isPressed = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        let completionPercentage = answersService.getCompletionPercentage(for: subcategory)
        let rowHeight = rowHeightForDynamicType()
        let horizontalPadding = horizontalPaddingForDynamicType()
        
        Button {
            HapticManager.shared.lightImpact()
            router.push(.learning(
                subcategoryName: subcategory.name,
                categoryName: subcategory.categoryName
            ))
        } label: {
            HStack(spacing: 12) {
                // Subcategory name
                Text(subcategory.name)
                    .font(.body.weight(.semibold))
                    .fontDesign(.rounded)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Question count
                Text("\(subcategory.questionCount)")
                    .font(.system(.title2, design: .rounded).weight(.heavy))
                    .foregroundColor(.white)
            }
            .frame(minHeight: rowHeight)
            .padding(.horizontal, horizontalPadding)
            .background(
                ZStack {
                    // Base background (unfilled) – system gray 3
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color(.systemGray3))
                    
                    // Progress bar filling from left to right – AppCaribean from assets
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color("AppCaribean"))
                            .frame(width: geometry.size.width * completionPercentage)
                    }
                }
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(NoEffectButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .buttonPressAnimation(isPressed: $isPressed)
        .padding(.horizontal, 8)
    }
    
    private func rowHeightForDynamicType() -> CGFloat {
        switch dynamicTypeSize {
        case .xSmall, .small, .medium:
            return 55
        case .large:
            return 60
        case .xLarge:
            return 68
        case .xxLarge, .xxxLarge:
            return 76
        default:
            return 84
        }
    }
    
    private func horizontalPaddingForDynamicType() -> CGFloat {
        switch dynamicTypeSize {
        case .xSmall, .small, .medium:
            return 16
        case .large:
            return 18
        case .xLarge:
            return 20
        default:
            return 22
        }
    }
}

// NoEffectButtonStyle is now defined in Core/Shared/Modifiers/NoEffectButtonStyle.swift

// MARK: - Search Question Card
private struct SearchQuestionCard: View {
    let question: QuestionModel
    let subcategoryName: String
    let matchedByTranslation: Bool
    @EnvironmentObject var languageManager: LanguageManager
    @State private var isPressed = false
    
    private var translatedQuestion: QuestionModel? {
        guard matchedByTranslation else { return nil }
        return ContentService.shared.getTranslatedQuestion(id: question.id)
    }
    
    var body: some View {
        NavigationLink(destination: LearningView(subcategory: SubcategoryModel(
            name: subcategoryName,
            categoryName: "",
            questions: [question]
        ), usesRouterNavigation: false).environmentObject(languageManager)) {
            VStack(alignment: .leading, spacing: 8) {
                // Question text (app language)
                Text(question.text)
                    .font(.callout.weight(.semibold))
                    .fontDesign(.rounded)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                // Translation text (only if matched by translation)
                if matchedByTranslation, let translated = translatedQuestion, translated.text != question.text {
                    Text(translated.text)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .padding(.top, 4)
                }
                
                // Question ID and subcategory
                HStack(spacing: 8) {
                    Text("question_label".localized + " \(question.id)")
                        .font(.caption.weight(.semibold))
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Text(subcategoryName)
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {
            HapticManager.shared.lightImpact()
        })
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var router = AppRouter()

    NavigationStack(path: $router.navigationPath) {
        CategoriesView()
            .environmentObject(LanguageManager())
            .environment(router)
    }
}
