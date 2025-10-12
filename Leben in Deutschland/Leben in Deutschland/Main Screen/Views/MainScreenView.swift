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
    
    var body: some View {
        NavigationStack {
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
        }
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
    
    private func handleCategorySelection(_ destination: MainListModel.CategoryDestination) {
        switch destination {
        case .startLearning:
            // Navigate to StartLearningView - Will be implemented later
            print("Start Learning selected")
        case .learnByTopics:
            // Navigate to LearnByTopicsView - Will be implemented later
            print("Learn by Topics selected")
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
