import SwiftUI

// MARK: - Tab Bar View
/// Root tab navigation that hosts the primary app sections.
/// HIG-compliant tab bar: bottom placement, translucent, 3–5 tabs with labels.
struct TabBarView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var premiumManager: PremiumManager
    @State private var selectedTab: TabIdentifier = .learn

    // MARK: - Tab Identifier (legacy selection binding)
    enum TabIdentifier: Hashable {
        case learn
        case test
        case progress
        case settings
        case search
    }

    // MARK: - Body
    var body: some View {
        if #available(iOS 18.0, *) {
            tabViewiOS18
        } else {
            tabViewLegacy
        }
    }

    @available(iOS 18.0, *)
    private var tabViewiOS18: some View {
        TabView {
            Tab("tab_learn_title".localized, systemImage: "book.fill") {
                HomeView()
            }
            .accessibilityHint("tab_learn_hint".localized)

            Tab("tab_test_title".localized, systemImage: "checkmark.seal.fill") {
                TestTabView()
            }
            .accessibilityHint("tab_test_hint".localized)

            Tab("tab_progress_title".localized, systemImage: "chart.bar.fill") {
                ProgressTabView()
            }
            .accessibilityHint("tab_progress_hint".localized)

            Tab("tab_settings_title".localized, systemImage: "gear") {
                SettingsDashboardView()
            }
            .accessibilityHint("tab_settings_hint".localized)

            Tab("tab_search_title".localized, systemImage: "magnifyingglass", role: .search) {
                SearchTabView()
            }
            .accessibilityHint("tab_search_hint".localized)
        }
        .tint(Color.accentColor)
        .compactTabBarSpacing(0)
        .id(languageManager.currentAppLanguage)
        .accessibilityLabel("main_tab_bar_accessibility_label".localized)
        .paywallSheet(premiumManager: premiumManager)
    }

    @ViewBuilder
    private var tabViewLegacy: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("tab_learn_title".localized, systemImage: "book.fill")
                }
                .tag(TabIdentifier.learn)
            TestTabView()
                .tabItem {
                    Label("tab_test_title".localized, systemImage: "checkmark.seal.fill")
                }
                .tag(TabIdentifier.test)
            ProgressTabView()
                .tabItem {
                    Label("tab_progress_title".localized, systemImage: "chart.bar.fill")
                }
                .tag(TabIdentifier.progress)
            SettingsDashboardView()
                .tabItem {
                    Label("tab_settings_title".localized, systemImage: "gear")
                }
                .tag(TabIdentifier.settings)

            SearchTabView()
                .tabItem {
                    Label("tab_search_title".localized, systemImage: "magnifyingglass")
                }
                .tag(TabIdentifier.search)
        }
        .tint(Color.accentColor)
        .compactTabBarSpacing(0)
        .onChange(of: selectedTab) { _, _ in
            HapticManager.shared.selectionChanged()
        }
        .id(languageManager.currentAppLanguage)
        .paywallSheet(premiumManager: premiumManager)
    }
}

// MARK: - Paywall Sheet Modifier
private extension View {
    func paywallSheet(premiumManager: PremiumManager) -> some View {
        sheet(isPresented: Binding(
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
#Preview("Tab Bar View") {
    TabBarView()
        .environmentObject(LanguageManager())
        .environmentObject(StateManager.shared)
        .environmentObject(SoundManager.shared)
        .environmentObject(AppFlow())
        .environmentObject(PremiumManager.shared)
        .environmentObject(FavoritesManager.shared)
}
