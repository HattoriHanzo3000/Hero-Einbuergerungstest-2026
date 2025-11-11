import SwiftUI

// MARK: - Main Screen View
struct MainScreenView: View {
    @State private var showDialog = false
    @State private var savedTestDate: Date? = UserDefaults.standard.object(forKey: "selectedTestDate") as? Date
    
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var stateManager: StateManager
    @State private var router = AppRouter()
    
    var body: some View {
        ZStack {
            NavigationStack(path: $router.navigationPath) {
                VStack(spacing: 0) {
                    // Header section - Federal state button + Mascot (combined as one section)
                    MainHeaderContent(
                        showDialog: $showDialog,
                        savedTestDate: $savedTestDate
                    )
                    
                    // Scrollable main categories section
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: MainScreenConstants.adaptiveValue(16)) {
                            MainListContent(fillHeight: false) { destination in
                                handleCategorySelection(destination)
                            }
                            .padding(.top, MainScreenConstants.adaptiveValue(8))

                            Spacer(minLength: MainScreenConstants.adaptiveValue(24))
                        }
                        .padding(.horizontal)
                        .padding(.bottom, MainScreenConstants.adaptiveValue(16))
                    }
                    .frame(maxWidth: .infinity)
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
                .navigationDestination(for: AppRouter.Destination.self) { destination in
                    destinationView(for: destination)
                }
            }
            .zIndex(0)
            
        }
        .environment(router)
        .onAppear {
            // Show dialog with delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showDialog = true
            }
        }
    }
    
    // MARK: - Private Methods
    
    @ViewBuilder
    private func destinationView(for destination: AppRouter.Destination) -> some View {
        switch destination {
        case .categories:
            CategoriesView()
                .environmentObject(languageManager)
        case .learning(let subcategoryName, let categoryName):
            // Find the subcategory from ContentService
            if let subcategory = ContentService.shared.findSubcategory(
                named: subcategoryName,
                in: categoryName,
                language: languageManager.currentAppLanguage
            ) {
                LearningView(subcategory: subcategory)
                    .environmentObject(languageManager)
            } else {
                // Fallback if subcategory not found
                Text("Content not available")
                    .foregroundColor(.secondary)
            }
        case .settings:
            SettingsDashboardView()
                .environmentObject(languageManager)
                .environmentObject(stateManager)
        case .favorites:
            // Will be implemented later
            Text("Favorites View")
                .navigationTitle("Favorites")
        }
    }
    
    private func handleCategorySelection(_ destination: MainListModel.CategoryDestination) {
        switch destination {
        case .startLearning:
            // Navigate to StartLearningView - Will be implemented later
            print("Start Learning selected")
        case .learnByTopics:
            // Handled by NavigationLink in MainListContent
            break
        case .favorites:
            // Navigate to FavoritesView - Will be implemented later
            print("Favorites selected")
        case .takeTest:
            // Navigate to TestSimulationView - Will be implemented later
            print("Take Test selected")
        }
    }
}

// MARK: - Preview
#Preview {
    MainScreenView()
        .environmentObject(LanguageManager())
        .environmentObject(StateManager())
}
