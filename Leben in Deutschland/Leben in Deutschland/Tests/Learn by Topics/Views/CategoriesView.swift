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
    
    @StateObject private var viewModel = CategoriesViewModel()
    @ObservedObject private var answersService = AnswersService.shared
    @State private var selectedCategory: CategoryModel?
    @State private var showSubcategories = false
    @State private var expandedCategoryNames: Set<String> = []
    @State private var searchText = ""
    @State private var isSearchVisible = false
    @FocusState private var isSearchFocused: Bool
    @State private var isAtBottom = false
    @State private var isSearchButtonPressed = false
    @State private var isBackButtonPressed = false
    
    private let stateService = CategoriesStateService.shared
    
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
        
        // Limit to 50 results like old version
        return Array(results.prefix(50))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with rounded corners and shadow
            ZStack(alignment: .top) {
                // Shadow layer (stays in place)
                RoundedCorner(radius: 35, corners: [.bottomLeft, .bottomRight])
                    .fill(Color("Fill"))
                    .brightness(-0.3)
                    .frame(height: UIScreen.main.bounds.height * 0.1)
                    .ignoresSafeArea(.all, edges: .top)
                
                // Header content (moved up)
                GeometryReader { geometry in
                    let screenWidth = geometry.size.width
                    let sidePadding = screenWidth * 0.05
                    
                    ZStack {
                        // Back button (left arrow for navigation)
                        HStack {
                            ZStack {
                                // Rounded square background
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("MainButton"))
                                    .frame(width: 30, height: 30)
                                
                                // Cartoon-style glass effect - sharp highlight (2/3 coverage)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                .init(color: .clear, location: 0.0),
                                                .init(color: .clear, location: 0.60),
                                                .init(color: .white.opacity(0.6), location: 0.63),
                                                .init(color: .white.opacity(0.6), location: 0.68),
                                                .init(color: .clear, location: 0.70)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 30, height: 30)
                                
                                // Stroke
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    .frame(width: 30, height: 30)
                                
                                // Icon
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color("MainButtonText"))
                            }
                            .background(
                                // Shadow layer
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray))
                                    .frame(width: 30, height: isBackButtonPressed ? 31 : 34)
                                    .opacity(0.3)
                                    .offset(y: isBackButtonPressed ? 1 : 2)
                            )
                            .offset(y: isBackButtonPressed ? 1 : 0)
                            .scaleEffect(isBackButtonPressed ? 0.98 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: isBackButtonPressed)
                            .contentShape(RoundedRectangle(cornerRadius: 8))
                            .onTapGesture {
                                // Brief press animation on tap
                                isBackButtonPressed = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isBackButtonPressed = false
                                }
                                HapticManager.shared.lightImpact()
                                dismiss()
                            }
                            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                                isBackButtonPressed = pressing
                            }, perform: {})
                            .padding(.leading, sidePadding)
                            .accessibilityLabel("Back")
                            .accessibilityHint("Go back to main screen")
                            
                            Spacer()
                            
                            // Search button
                            ZStack {
                                // Rounded square background
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("MainButton"))
                                    .frame(width: 30, height: 30)
                                
                                // Cartoon-style glass effect - sharp highlight (2/3 coverage)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(stops: [
                                                .init(color: .clear, location: 0.0),
                                                .init(color: .clear, location: 0.60),
                                                .init(color: .white.opacity(0.6), location: 0.63),
                                                .init(color: .white.opacity(0.6), location: 0.68),
                                                .init(color: .clear, location: 0.70)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 30, height: 30)
                                
                                // Stroke
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    .frame(width: 30, height: 30)
                                
                                // Icon
                                Image(systemName: isSearchVisible ? "xmark" : "magnifyingglass")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color("MainButtonText"))
                                    .animation(.none, value: isSearchVisible)
                            }
                            .background(
                                // Shadow layer
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray))
                                    .frame(width: 30, height: isSearchButtonPressed ? 31 : 34)
                                    .opacity(0.3)
                                    .offset(y: isSearchButtonPressed ? 1 : 2)
                            )
                            .offset(y: isSearchButtonPressed ? 1 : 0)
                            .scaleEffect(isSearchButtonPressed ? 0.98 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: isSearchButtonPressed)
                            .contentShape(RoundedRectangle(cornerRadius: 8))
                            .onTapGesture {
                                // Brief press animation on tap
                                isSearchButtonPressed = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isSearchButtonPressed = false
                                }
                                HapticManager.shared.lightImpact()
                                withAnimation {
                                    isSearchVisible.toggle()
                                    if !isSearchVisible {
                                        searchText = ""
                                        isSearchFocused = false
                                    }
                                }
                            }
                            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                                isSearchButtonPressed = pressing
                            }, perform: {})
                            .padding(.trailing, sidePadding)
                            .accessibilityLabel(isSearchVisible ? "Close search" : "Search categories")
                        }
                        
                        // Title
                        Text("learn_by_topics_title".localized)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(Color(.systemGray6))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .padding(.horizontal, sidePadding + 44)
                            .accessibilityAddTraits(.isHeader)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: UIScreen.main.bounds.height * 0.1)
                .background(
                    RoundedRectangle(cornerRadius: 0, style: .continuous)
                        .fill(Color("Fill"))
                        .clipShape(
                            RoundedCorner(radius: 35, corners: [.bottomLeft, .bottomRight])
                        )
                        .ignoresSafeArea(.all, edges: .top)
                )
                .offset(y: -6)
            }
            .frame(height: UIScreen.main.bounds.height * 0.1 + 6)
            
            // Content area with system white background
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea(edges: .bottom)
                
                if viewModel.isLoading || viewModel.categories.isEmpty && viewModel.errorMessage == nil {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(Color("AppOrange"))
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
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    HapticManager.shared.lightImpact()
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary)
                                }
                                .accessibilityLabel("Clear search")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6).opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
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
                                .padding(.top, 24)
                                .padding(.bottom, 32)
                            }
                        }
                    }
                }
            }
            .offset(y: -3)
        }
        .background(Color(.systemBackground))
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Category header button - two-part design inside white block
            HStack(alignment: .center, spacing: 12) {
                    // Square icon container
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("MainButton"))
                            .frame(width: 60, height: 60)
                        
                        // Cartoon-style glass effect - sharp highlight (2/3 coverage)
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: .clear, location: 0.0),
                                        .init(color: .clear, location: 0.60),
                                        .init(color: .white.opacity(0.6), location: 0.63),
                                        .init(color: .white.opacity(0.6), location: 0.68),
                                        .init(color: .clear, location: 0.70)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        // Thin stroke
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: categoryIcon)
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                            .foregroundColor(isCategoryCompleted ? Color("AppOrange") : Color("MainButtonText"))
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray))
                            .frame(width: 60, height: isPressed ? 61 : 64)
                            .opacity(0.3)
                            .offset(y: isPressed ? 1 : 2)
                    )
                    .offset(y: isPressed ? 1 : 0)
                    
                    // Rectangle text container
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("MainButton"))
                            .frame(height: 60)
                        
                        // Cartoon-style glass effect - sharp highlight (2/3 coverage)
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: .clear, location: 0.0),
                                        .init(color: .clear, location: 0.60),
                                        .init(color: .white.opacity(0.6), location: 0.63),
                                        .init(color: .white.opacity(0.6), location: 0.68),
                                        .init(color: .clear, location: 0.70)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 60)
                        
                        // Thin stroke
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            .frame(height: 60)
                        
                        HStack(spacing: 8) {
                            Text(category.name)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(isCategoryCompleted ? Color("AppOrange") : Color("MainButtonText"))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(isCategoryCompleted ? Color("AppOrange") : Color("MainButtonText"))
                                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        }
                        .padding(.horizontal, 16)
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray))
                            .frame(height: isPressed ? 61 : 64)
                            .opacity(0.3)
                            .offset(y: isPressed ? 1 : 2)
                    )
                    .offset(y: isPressed ? 1 : 0)
                }
                .padding(16)
            .contentShape(Rectangle())
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .onTapGesture {
                // Brief press animation on tap
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
                HapticManager.shared.lightImpact()
                onToggle()
            }
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
            
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
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("Block"))
        )
        .overlay(
            // Thin stroke (same as buttons)
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .background(
            // Shadow layer (same as buttons)
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray))
                .opacity(0.3)
                .offset(y: 1)
                .padding(.top, -1)
                .padding(.bottom, -3)
        )
        }
    }

// MARK: - Subcategory Button
private struct SubcategoryButton: View {
    let subcategory: SubcategoryModel
    @ObservedObject var answersService: AnswersService
    @Environment(AppRouter.self) private var router
    @State private var isPressed = false
    
    var body: some View {
        let completionPercentage = answersService.getCompletionPercentage(for: subcategory)
        
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
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Question count
                Text("\(subcategory.questionCount)")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary)
            }
            .frame(height: 55)
            .padding(.horizontal, 16)
            .background(
                ZStack {
                    // Base background
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                    
                    // Progress bar filling from left to right
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("AppOrange"))
                            .frame(width: geometry.size.width * completionPercentage)
                    }
                    
                    // Cartoon-style glass effect - sharp highlight (2/3 coverage)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .clear, location: 0.0),
                                    .init(color: .clear, location: 0.60),
                                    .init(color: .white.opacity(0.6), location: 0.63),
                                    .init(color: .white.opacity(0.6), location: 0.68),
                                    .init(color: .clear, location: 0.70)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Thin stroke on top
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                }
            )
            .background(
                // Shadow layer
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray))
                    .frame(height: isPressed ? 56 : 59)
                    .opacity(0.3)
                    .offset(y: isPressed ? 1 : 2)
            )
            .offset(y: isPressed ? 1 : 0)
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
}

// MARK: - Custom Button Style
struct NoEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // No opacity, color, or scale changes - completely static
    }
}

// MARK: - Search Question Card
private struct SearchQuestionCard: View {
    let question: QuestionModel
    let subcategoryName: String
    @EnvironmentObject var languageManager: LanguageManager
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: LearningView(subcategory: SubcategoryModel(
            name: subcategoryName,
            categoryName: "",
            questions: [question]
        )).environmentObject(languageManager)) {
            VStack(alignment: .leading, spacing: 8) {
                // Question text
                Text(question.text)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                // Question ID and subcategory
                HStack(spacing: 8) {
                    Text("question_label".localized + " \(question.id)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Text(subcategoryName)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                    )
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


