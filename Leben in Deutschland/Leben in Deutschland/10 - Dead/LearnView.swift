//
//  LearnView.swift
//  Leben in Deutschland
//
//  Launchpad for the Learn experience with a bold editorial header and curated pathways.
//

import SwiftUI

// MARK: - Learn View
struct LearnView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @StateObject private var optionsViewModel = LearnOptionsViewModel()
    @State private var hasConfiguredSelectionHandler = false
    @State private var router = AppRouter()
    @State private var lastSelectedOptionID: UUID?
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    private var horizontalSafeInset: CGFloat { layoutMetrics.adaptive(24) }
    private var verticalSpacing: CGFloat { layoutMetrics.adaptive(28) }
    
    // Tab bar height: standard iOS tab bar is ~49pt
    private var tabBarHeight: CGFloat { 49 }
    
    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            GeometryReader { geometry in
                VStack(spacing: verticalSpacing) {
                    LearnHeaderContent()
                        .padding(.top, geometry.safeAreaInsets.top + layoutMetrics.adaptive(24))
                        .padding(.bottom, layoutMetrics.adaptive(20))
                    
                    VStack(spacing: verticalSpacing) {
                        LearnOptionsCarouselView(
                            options: optionsViewModel.options,
                            highlightedOptionID: $optionsViewModel.highlightedOptionID,
                            onSelect: handleSelection,
                            containerWidth: geometry.size.width,
                            horizontalSafeInset: 0
                        )
                        
                        Spacer()
                    }
                }
                .padding(.bottom, layoutMetrics.adaptive(32) + tabBarHeight + geometry.safeAreaInsets.bottom)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                .background(Color(.systemBackground))
            }
            .ignoresSafeArea(edges: .top)
            .navigationDestination(for: AppRouter.Destination.self) { destination in
                destinationView(for: destination)
            }
        }
        .toolbar(.visible, for: .tabBar) // Always show tab bar in carousel menu
        .environment(router)
        .onAppear {
            configureSelectionHandlerIfNeeded()
            // Check if we need to highlight a specific option (e.g., after returning from test)
            if optionsViewModel.highlightedOptionID == nil {
                optionsViewModel.highlightedOptionID = optionsViewModel.options.first?.id
            }
        }
        .onChange(of: router.navigationPath.count) { _, count in
            // When navigation path is cleared (popped to root), restore the last selected option
            if count == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let lastSelectedID = lastSelectedOptionID,
                       let option = optionsViewModel.options.first(where: { $0.id == lastSelectedID }) {
                        optionsViewModel.highlightedOptionID = option.id
                    } else if optionsViewModel.highlightedOptionID == nil {
                        // Fallback to first option if no last selected
                        optionsViewModel.highlightedOptionID = optionsViewModel.options.first?.id
                    }
                }
            }
        }
    }
}

// MARK: - Private Methods
private extension LearnView {
    func handleSelection(_ option: LearnOptionModel) {
        optionsViewModel.select(option)
    }
    
    func configureSelectionHandlerIfNeeded() {
        guard hasConfiguredSelectionHandler == false else { return }
        optionsViewModel.setSelectionHandler { option in
            navigate(for: option)
        }
        hasConfiguredSelectionHandler = true
    }
    
    func navigate(for option: LearnOptionModel) {
        // Track the selected option so we can restore it when navigating back
        lastSelectedOptionID = option.id
        optionsViewModel.highlightedOptionID = option.id
        
        switch option.titleKey {
        case "learn_option_spaced_repetition_title":
            router.push(.spacedRepetition)
        case "learn_option_topics_title":
            router.push(.categories)
        case "learn_option_test_title":
            router.push(.testSimulation)
        case "learn_option_favorites_title":
            router.push(.favorites)
        default:
            break
        }
    }
    
}

// MARK: - Navigation Destination
private extension LearnView {
    @ViewBuilder
    func destinationView(for destination: AppRouter.Destination) -> some View {
        switch destination {
        case .categories:
            CategoriesView()
                .environmentObject(languageManager)
        case .spacedRepetition:
            SpacedRepetitionView()
                .environmentObject(languageManager)
        case .learning(let subcategoryName, let categoryName):
            LearningDestinationView(
                subcategoryName: subcategoryName,
                categoryName: categoryName
            )
            .environmentObject(languageManager)
        case .favorites:
            FavoritesView()
                .environmentObject(languageManager)
        case .testCountdown:
            TestCountdownView {
                router.push(.testSimulation)
            }
            .environmentObject(languageManager)
            .environmentObject(StateManager.shared)
        case .testSimulation:
            TestSessionView()
                .environmentObject(languageManager)
                .environmentObject(FavoritesManager.shared)
                .environmentObject(StateManager.shared)
        }
    }
}

// MARK: - Preview
#Preview("Learn View – Hero Header") {
    LearnView()
        .environmentObject(LanguageManager())
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

