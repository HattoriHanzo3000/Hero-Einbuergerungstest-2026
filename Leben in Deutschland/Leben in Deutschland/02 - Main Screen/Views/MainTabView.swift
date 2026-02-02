import SwiftUI

// MARK: - Main Tab View
/// Root tab navigation that hosts the primary app sections.
/// Currently provides two tabs (Home, Settings) with matching SF Symbols.
struct MainTabView: View {
    
    // MARK: - Tab Identifier
    enum Tab: Hashable {
        case home
        case test
        case premium
        case settings
    }
    
    // MARK: - State
    @State private var selectedTab: Tab = .home
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label {
                        Text("tab_home_title".localized)
                    } icon: {
                        Image(systemName: "house.fill")
                    }
                }
                .tag(Tab.home)
            
            TestTabView()
                .tabItem {
                    Label {
                        Text("tab_test_title".localized)
                    } icon: {
                        Image(systemName: "checkmark.seal.fill")
                    }
                }
                .tag(Tab.test)
            
            PremiumHubView()
                .tabItem {
                    Label {
                        Text("tab_premium_title".localized)
                    } icon: {
                        Image(systemName: "crown.fill")
                    }
                }
                .tag(Tab.premium)
            
            SettingsDashboardView()
                .tabItem {
                    Label {
                        Text("tab_settings_title".localized)
                    } icon: {
                        Image(systemName: "gear")
                    }
                }
                .tag(Tab.settings)
        }
        .accessibilityLabel("main_tab_bar_accessibility_label".localized)
    }
}

// MARK: - Preview
#Preview("Main Tab View") {
    MainTabView()
        .environmentObject(LanguageManager())
        .environmentObject(StateManager.shared)
        .environmentObject(SoundManager.shared)
        .environmentObject(AppFlow())
}

