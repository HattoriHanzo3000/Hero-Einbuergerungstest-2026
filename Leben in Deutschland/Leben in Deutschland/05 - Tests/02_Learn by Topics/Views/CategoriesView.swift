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
    
    // Flat list of matching questions for search
    var searchResults: [(question: QuestionModel, subcategory: String)] {
        guard !searchText.isEmpty else { return [] }
        
        let query = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return [] }
        
        var results: [(question: QuestionModel, subcategory: String)] = []
        
        // Search through all questions in all categories and subcategories
        for category in viewModel.categories {
            for subcategory in category.subcategories {
                for question in subcategory.questions {
                    // Search by question ID (exact match or contains)
                    if question.id.lowercased().contains(query) {
                        results.append((question, subcategory.name))
                        continue
                    }
                    
                    // Search in question text
                    if question.text.lowercased().contains(query) {
                        results.append((question, subcategory.name))
                        continue
                    }
                    
                    // Search in question options
                    if question.options.contains(where: { $0.lowercased().contains(query) }) {
                        results.append((question, subcategory.name))
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
                VStack(alignment: .leading, spacing: layoutMetrics.adaptive(12)) {
                    HStack {
                        AdaptiveIconButton.backButton {
                        dismiss()
                        }
                        
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
                            accessibilityHint: "Toggle search mode"
                        )
                                .animation(.none, value: isSearchVisible)
                        }
                    
                    Text("learn_by_topics_title".localized)
                        .font(.system(.title, design: .rounded).weight(.bold))
                        .foregroundColor(Color(.systemGray6))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8) // Adapts to Dynamic Type
                        .accessibilityAddTraits(.isHeader)
                }
                .padding(.vertical, layoutMetrics.adaptive(18))
                .padding(.horizontal, layoutMetrics.adaptive(20))
                .frame(minHeight: 68) // Consistent minimum height across devices
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.accentColor)
                )
                .padding(.horizontal) // System padding for island effect
                .padding(.top, 8) // Visual spacing from safe area
                
                // Spacing between header and content
                Spacer()
                    .frame(height: 8)
                
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
                                                    subcategoryName: result.subcategory
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
        .navigationBarHidden(true)
        .task {
            await viewModel.loadCategories(for: languageManager.currentAppLanguage)
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
        .toolbar(.visible, for: .tabBar)
        .onAppear {
            // Ensure tab bar is visible
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showTabBar()
            }
        }
        .sheet(isPresented: $showSubcategories) {
            if let category = selectedCategory {
                SubcategoriesView(category: category)
                    .environmentObject(languageManager)
            }
        }
    }
    
    private func showTabBar() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let tabBarController = findTabBarController(in: window.rootViewController) else { return }
        let tabBar = tabBarController.tabBar
        
        guard tabBar.isHidden else { return }
        
        let height = tabBar.bounds.height > 0 ? tabBar.bounds.height : (tabBar.frame.height > 0 ? tabBar.frame.height : 49)
        
        tabBar.isHidden = false
        tabBar.transform = CGAffineTransform(translationX: 0, y: height)
        tabBar.alpha = 0
        
        UIView.animate(
            withDuration: 0.45,
            delay: 0,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.4,
            options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseOut],
            animations: {
                tabBar.transform = .identity
                tabBar.alpha = 1
            }
        )
    }
    
    private func findTabBarController(in viewController: UIViewController?) -> UITabBarController? {
        guard let viewController = viewController else { return nil }
        
        if let tabBarController = viewController as? UITabBarController {
            return tabBarController
        }
        
        for child in viewController.children {
            if let tabBarController = findTabBarController(in: child) {
                return tabBarController
            }
        }
        
        if let presented = viewController.presentedViewController {
            return findTabBarController(in: presented)
        }
        
        return nil
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
                            .foregroundColor(isCategoryCompleted ? Color("AppOrange") : Color(.systemBackground))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    HStack(spacing: 12) {
                            Text(category.name)
                            .font(.title3.weight(.semibold))
                                .fontDesign(.rounded)
                                .foregroundColor(isCategoryCompleted ? Color("AppOrange") : Color(.systemBackground))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(isCategoryCompleted ? Color("AppOrange") : Color(.systemBackground))
                                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        }
                    }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, containerPadding)
                .padding(.horizontal, containerPadding)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.accentColor)
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
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(.systemGray6))
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
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Question count
                Text("\(subcategory.questionCount)")
                    .font(.system(.title2, design: .rounded).weight(.heavy))
                    .foregroundColor(.primary)
            }
            .frame(minHeight: rowHeight)
            .padding(.horizontal, horizontalPadding)
            .background(
                ZStack {
                    // Base background
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color(.systemGray5))
                    
                    // Progress bar filling from left to right
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color("AppOrange"))
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
    @EnvironmentObject var languageManager: LanguageManager
    @State private var isPressed = false
    @State private var showingFeedbackReport = false
    
    var body: some View {
        NavigationLink(destination: LearningView(subcategory: SubcategoryModel(
            name: subcategoryName,
            categoryName: "",
            questions: [question]
        ), usesRouterNavigation: false).environmentObject(languageManager)) {
            VStack(alignment: .leading, spacing: 8) {
                // Question text
                Text(question.text)
                    .font(.callout.weight(.semibold))
                    .fontDesign(.rounded)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                // Question ID and subcategory
                HStack(spacing: 8) {
                    HStack(spacing: 6) {
                    Text("question_label".localized + " \(question.id)")
                        .font(.caption.weight(.semibold))
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            showingFeedbackReport = true
                        }) {
                            Image(systemName: "flag.fill")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.accentColor)
                        }
                    }
                    
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
        .sheet(isPresented: $showingFeedbackReport) {
            FeedbackReportView(
                questionId: question.id,
                questionText: question.text,
                category: question.category
            )
            .environmentObject(languageManager)
        }
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
