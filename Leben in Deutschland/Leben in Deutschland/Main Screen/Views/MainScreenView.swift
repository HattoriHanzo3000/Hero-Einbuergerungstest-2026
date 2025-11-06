import SwiftUI

// MARK: - Main Screen View
struct MainScreenView: View {
    @State private var showDialog = false
    @State private var showSettings = false
    @State private var showDatePicker = false
    @State private var showLanguageSelection = false
    @State private var showFederalStatesSelection = false
    @State private var showPremium = false
    @State private var selectedDate = Date()
    @State private var savedTestDate: Date? = UserDefaults.standard.object(forKey: "selectedTestDate") as? Date
    
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var stateManager: StateManager
    @State private var router = AppRouter()
    
    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            VStack(spacing: 0) {
                // Header section - Federal state button + Mascot (combined as one section)
                MainHeaderContent(
                    showDialog: $showDialog,
                    onStateButtonTapped: {
                        showFederalStatesSelection = true
                    }
                )
                
                // Main categories section
                MainListContent { destination in
                    handleCategorySelection(destination)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                Spacer()
                
                // Footer section - 4 buttons
                MainFooterContent(
                    savedTestDate: $savedTestDate,
                    onLanguageTapped: {
                        showLanguageSelection = true
                    },
                    onDateTapped: {
                        // Load saved date or use today
                        selectedDate = savedTestDate ?? Date()
                        showDatePicker = true
                    },
                    onSettingsTapped: {
                        showSettings = true
                    },
                    onPremiumTapped: {
                        showPremium = true
                    }
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .navigationDestination(for: AppRouter.Destination.self) { destination in
                destinationView(for: destination)
            }
        }
        .environment(router)
        .onAppear {
            // Show dialog with delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showDialog = true
            }
        }
        // MARK: - Sheets and Full Screen Covers
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(languageManager)
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(
                selectedDate: $selectedDate,
                locale: getLocale(for: languageManager.currentAppLanguage),
                hasExistingDate: savedTestDate != nil,
                onSave: { date in
                    HapticManager.shared.lightImpact()
                    UserDefaults.standard.set(date, forKey: "selectedTestDate")
                    savedTestDate = date  // Update footer state
                    showDatePicker = false
                },
                onClear: {
                    HapticManager.shared.lightImpact()
                    UserDefaults.standard.removeObject(forKey: "selectedTestDate")
                    savedTestDate = nil  // Clear footer state
                    showDatePicker = false
                },
                onCancel: {
                    HapticManager.shared.lightImpact()
                    showDatePicker = false
                }
            )
        }
        .sheet(isPresented: $showLanguageSelection) {
            LanguageView()
                .environmentObject(languageManager)
        }
        .sheet(isPresented: $showFederalStatesSelection) {
            FederalStatesView()
                .environmentObject(stateManager)
        }
        .sheet(isPresented: $showPremium) {
            NavigationView {
                // AdRemovalView() - Will be implemented later
                Text("Premium Features")
                    .navigationTitle("Premium")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showPremium = false
                            }
                        }
                    }
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
            SettingsView()
                .environmentObject(languageManager)
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
    
    // MARK: - Helper Methods
    
    /// Returns locale for given language code
    private func getLocale(for languageCode: String) -> Locale {
        switch languageCode {
        case "ru": return Locale(identifier: "ru_RU")
        case "de": return Locale(identifier: "de_DE")
        case "en": return Locale(identifier: "en_US")
        case "uk": return Locale(identifier: "uk_UA")
        default: return Locale.current
        }
    }
}

// MARK: - Preview
#Preview {
    MainScreenView()
        .environmentObject(LanguageManager())
        .environmentObject(StateManager())
}
