import SwiftUI

// MARK: - Main Tab View
/// Root tab navigation that hosts the primary app sections.
/// Four tabs: Learn, Test, Progress, Settings.
struct MainTabView: View {
    @EnvironmentObject private var premiumManager: PremiumManager
    
    // MARK: - Tab Identifier
    enum Tab: Hashable {
        case learn
        case test
        case progress
        case settings
    }
    
    // MARK: - State
    @State private var selectedTab: Tab = .learn
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label {
                        Text("tab_learn_title".localized)
                    } icon: {
                        Image(systemName: "book.fill")
                    }
                }
                .tag(Tab.learn)
                .accessibilityHint("tab_learn_hint".localized)
            
            TestTabView()
                .tabItem {
                    Label {
                        Text("tab_test_title".localized)
                    } icon: {
                        Image(systemName: "checkmark.seal.fill")
                    }
                }
                .tag(Tab.test)
                .accessibilityHint("tab_test_hint".localized)
            
            ProgressTabView()
                .tabItem {
                    Label {
                        Text("tab_progress_title".localized)
                    } icon: {
                        Image(systemName: "chart.bar.fill")
                    }
                }
                .tag(Tab.progress)
                .accessibilityHint("tab_progress_hint".localized)
            
            SettingsDashboardView()
                .tabItem {
                    Label {
                        Text("tab_settings_title".localized)
                    } icon: {
                        Image(systemName: "gear")
                    }
                }
                .tag(Tab.settings)
                .accessibilityHint("tab_settings_hint".localized)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear.frame(height: 12)
        }
        .accessibilityLabel("main_tab_bar_accessibility_label".localized)
        .sheet(isPresented: Binding(
            get: { premiumManager.showPaywall },
            set: { premiumManager.showPaywall = $0 }
        ), onDismiss: {
            premiumManager.showPaywall = false
        }) {
            PaywallView()
                .environmentObject(premiumManager)
        }
    }
}

// MARK: - Preview
#Preview("Main Tab View") {
    MainTabView()
        .environmentObject(LanguageManager())
        .environmentObject(StateManager.shared)
        .environmentObject(SoundManager.shared)
        .environmentObject(AppFlow())
        .environmentObject(PremiumManager.shared)
        .environmentObject(FavoritesManager.shared)
}

