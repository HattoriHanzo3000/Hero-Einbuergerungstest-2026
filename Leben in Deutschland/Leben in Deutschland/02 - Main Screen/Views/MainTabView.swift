import SwiftUI

// MARK: - Main Tab View
/// Root tab navigation that hosts the primary app sections.
/// Currently provides four tabs (Home, Learn, Premium, Settings) with matching SF Symbols.
struct MainTabView: View {
    
    // MARK: - Environment
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var soundManager: SoundManager
    
    // MARK: - Tab Identifier
    enum Tab: Hashable {
        case home
        case learn
        case premium
        case settings
        case settingsBeta
    }
    
    // MARK: - State
    @State private var selectedTab: Tab = .home
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            MainScreenView()
                .tabItem {
                    Label("tab_home_title".localized, systemImage: "house.fill")
                }
                .tag(Tab.home)
            
            TabPlaceholderView(
                titleKey: "tab_learn_title",
                systemImage: "book.fill"
            )
            .tabItem {
                Label("tab_learn_title".localized, systemImage: "book.fill")
            }
            .tag(Tab.learn)
            
            TabPlaceholderView(
                titleKey: "tab_premium_title",
                systemImage: "crown.fill"
            )
            .tabItem {
                Label("tab_premium_title".localized, systemImage: "crown.fill")
            }
            .tag(Tab.premium)
            
            SettingsView()
            .tabItem {
                Label("tab_settings_title".localized, systemImage: "gear")
            }
            .tag(Tab.settings)
            
            SettingsBetaView()
                .environmentObject(languageManager)
                .environmentObject(StateManager())
                .environmentObject(soundManager)
                .tabItem {
                    Label("tab_settings_beta_title".localized, systemImage: "gearshape.2.fill")
                }
                .tag(Tab.settingsBeta)
        }
        .accessibilityLabel("main_tab_bar_accessibility_label".localized)
    }
}

// MARK: - Placeholder Tab View
/// Simple placeholder view for tabs that are not yet implemented.
private struct TabPlaceholderView: View {
    let titleKey: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: MainScreenConstants.adaptiveValue(16)) {
            Image(systemName: systemImage)
                .font(.system(size: MainScreenConstants.adaptiveValue(48), weight: .semibold, design: .rounded))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)
            
            Text(titleKey.localized)
                .font(.system(.title2, design: .rounded).weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.primary)
                .accessibilityLabel(titleKey.localized)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview
#Preview("Main Tab View") {
    MainTabView()
        .environmentObject(LanguageManager())
        .environmentObject(StateManager())
}

