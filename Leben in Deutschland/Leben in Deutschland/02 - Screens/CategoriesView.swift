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
    @State private var selectedCategory: CategoryModel?
    @State private var showSubcategories = false
    @State private var expandedCategoryNames: Set<String> = []
    @State private var searchText = ""
    @State private var isSearchVisible = false
    @FocusState private var isSearchFocused: Bool
    @State private var isAtBottom = false
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
    
    private var headerVerticalPadding: CGFloat { layoutMetrics.adaptive(18) }
    private var headerHorizontalPadding: CGFloat { layoutMetrics.adaptive(20) }
    private var mascotToContentSpacing: CGFloat { layoutMetrics.adaptive(16) }
    private var mascotSize: CGFloat { layoutMetrics.adaptive(120) }
    private var titleToMessageSpacing: CGFloat { layoutMetrics.adaptive(6) }
    
    // Flat list of matching questions for search (searches in both app language and translation language)
    var searchResults: [(question: QuestionModel, subcategory: String, matchedByTranslation: Bool)] {
        guard !searchText.isEmpty else { return [] }
        
        let query = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }
        
        var results: [(question: QuestionModel, subcategory: String, matchedByTranslation: Bool)] = []
        var seenQuestionIds = Set<String>() // Track unique questions by ID
        
        let contentService = ContentService.shared
        
        // Search through all questions in all categories and subcategories
        for category in viewModel.categories {
            for subcategory in category.subcategories {
                for question in subcategory.questions {
                    // Skip if already added
                    guard !seenQuestionIds.contains(question.id) else { continue }
                    
                    var matches = false
                    var matchedByTranslation = false
                    
                    // Search by question ID (exact match or contains) - ID matches don't count as translation match
                    if question.id.lowercased().contains(query) {
                        matches = true
                    }
                    
                    // Search in question text (app language)
                    let matchedInAppLanguage = question.text.lowercased().contains(query) ||
                        question.options.contains(where: { $0.lowercased().contains(query) })
                    
                    if matchedInAppLanguage {
                        matches = true
                    }
                    
                    // Search in translated question text (translation language)
                    if let translatedQuestion = contentService.getTranslatedQuestion(id: question.id) {
                        let matchedInTranslation = translatedQuestion.text.lowercased().contains(query) ||
                            translatedQuestion.options.contains(where: { $0.lowercased().contains(query) })
                        
                        if matchedInTranslation {
                            matches = true
                            // Only mark as matchedByTranslation if match was in translation AND not in app language
                            // (if both match, prefer showing translation since user searched in translation language)
                            if !matchedInAppLanguage {
                                matchedByTranslation = true
                            } else {
                                // If both match, check if query matches translation better
                                // For simplicity, if translation matches, show it
                                matchedByTranslation = true
                            }
                        }
                    }
                    
                    if matches {
                        results.append((question, subcategory.name, matchedByTranslation))
                        seenQuestionIds.insert(question.id)
                    }
                }
            }
        }
        
        // Limit to 50 results
        return Array(results.prefix(50))
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header - Apple Design Awards quality: clarity, elegance, accessibility
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
                .padding(.vertical, headerVerticalPadding)
                .padding(.horizontal, headerHorizontalPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .background(LiquidGlassBackground(gradient: .blue))
                .clipShape(RoundedRectangle(cornerRadius: layoutMetrics.adaptive(32), style: .continuous))
                .overlay(HeaderBorderOverlay())
                .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
                .padding(.horizontal, layoutMetrics.adaptive(20))
                .padding(.top, layoutMetrics.adaptive(8))
                
                Divider()
                    .padding(.top, layoutMetrics.adaptive(12))
                
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
                        ScrollViewReader { scrollProxy in
                            ZStack {
                                ScrollView {
                                    VStack(spacing: 16) {
                                        // Scroll target for top
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(height: 1)
                                            .id("top")
                                        
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
                                                    // Save state immediately
                                                    stateService.saveExpandedCategories(expandedCategoryNames)
                                                    HapticManager.shared.lightImpact()
                                                },
                                                answersService: answersService
                                            )
                                        }
                                        
                                        // Scroll target for bottom
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(height: 1)
                                            .id("bottom")
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.top, 4)
                                    .padding(.bottom, 32)
                                }
                            }
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
            // Load saved state
            expandedCategoryNames = stateService.loadExpandedCategories()
            isAtBottom = stateService.loadScrollPosition()
        }
        .onDisappear {
            // Save current state
            stateService.saveExpandedCategories(expandedCategoryNames)
            stateService.saveScrollPosition(isAtBottom: isAtBottom)
        }
        .hidesTabBar()
        .tabBarHidden(true)
        .sheet(isPresented: $showSubcategories) {
            if let category = selectedCategory {
                SubcategoriesView(category: category)
                    .environmentObject(languageManager)
            }
        }
    }
}

// MARK: - Expandable Category View
private struct ExpandableCategoryView: View {
    let category: CategoryModel
    let isExpanded: Bool
    let onToggle: () -> Void
    @ObservedObject var answersService: AnswersService
    @State private var isPressed = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    // Check if all subcategories are completed
    private var isCategoryCompleted: Bool {
        category.subcategories.allSatisfy { subcategory in
            answersService.getCompletionPercentage(for: subcategory) >= 1.0
        }
    }
    
    // Get icon for category
    private var categoryIcon: String {
        switch category.name {
        case "Law and Constitution", "Recht und Verfassung", "Право и Конституция", "Право та Конституція":
            return "building.columns.fill"
        case "Family and Education", "Familie und Bildung", "Семья и образование", "Освіта та Сім'я":
            return "figure.2.and.child.holdinghands"
        case "State", "Staat", "Государство", "Держава":
            return "flag.fill"
        case "Elections", "Wahlen", "Выборы", "Вибори":
            return "checkmark.square.fill"
        case "State Institutions", "Staatsorgane", "Гос Органы", "Державні органи":
            return "building.2.fill"
        case "Economy and Work", "Wirtschaft und Arbeit", "Экономика и работа", "Робота та Економіка":
            return "briefcase.fill"
        case "Society and Culture", "Gesellschaft und Kultur", "Общество и Культура", "Суспільство та Культура":
            return "heart.square"
        case "History", "Geschichte", "История", "Історія":
            return "book.closed.fill"
        case "Europe", "Europa", "Европа", "Європа та ЄС":
            return "globe.europe.africa.fill"
        case "Federal States", "Bundesländer", "Федеральные земли", "Федеральні землі":
            return "mappin.and.ellipse"
        default:
            return "folder.fill"
        }
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
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
                HapticManager.shared.lightImpact()
                onToggle()
            }) {
                VStack(alignment: .leading, spacing: 12) {
                        Image(systemName: categoryIcon)
                        .font(.system(.title, design: .rounded).weight(.semibold))
                            .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    HStack(spacing: 12) {
                            Text(category.name)
                            .font(.title3.weight(.semibold))
                                .fontDesign(.rounded)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
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
                .overlay(
                    RoundedRectangle(cornerRadius: 33, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.45), Color.white.opacity(0.12)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.6
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.4), .white.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                )
            }
            .contentShape(Rectangle())
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .buttonStyle(.plain)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            
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
            RoundedRectangle(cornerRadius: 33, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.45), Color.white.opacity(0.12)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.6
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.4), .white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
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
        .padding(.horizontal, 8)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            if pressing {
                isPressed = true
            } else {
                // Brief hold after release for visual feedback
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    isPressed = false
                }
            }
        }, perform: {})
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
