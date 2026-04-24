import SwiftUI

// MARK: - Main View
/// Root tab navigation that hosts the primary app sections.
/// Mirrors B2's `MainView` role as the app-wide container with visible tab bar.
struct MainView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @AppStorage("appLanguage") private var appLanguage: String = LanguageManager.baseLanguageCode
    @State private var selectedTab: TabIdentifier = .learn

    enum TabIdentifier: Hashable {
        case learn
        case progress
        case settings
        case search
    }

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
            Tab("tab_learn_title".localized(for: appLanguage), systemImage: "book.fill") {
                HomeView()
            }
            .accessibilityHint("tab_learn_hint".localized(for: appLanguage))

            Tab("tab_progress_title".localized(for: appLanguage), systemImage: "gauge.with.dots.needle.bottom.50percent") {
                ProgressTabView()
            }
            .accessibilityHint("tab_progress_hint".localized(for: appLanguage))

            Tab("tab_settings_title".localized(for: appLanguage), systemImage: "gear") {
                SettingsDashboardView()
            }
            .accessibilityHint("tab_settings_hint".localized(for: appLanguage))

            Tab("tab_search_title".localized(for: appLanguage), systemImage: "magnifyingglass", role: .search) {
                SearchTabView()
            }
            .accessibilityHint("tab_search_hint".localized(for: appLanguage))
        }
        .tint(Color.accentColor)
        .compactTabBarSpacing(0)
        .accessibilityLabel("main_tab_bar_accessibility_label".localized(for: appLanguage))
        .task { await SubscriptionManager.shared.refreshPremiumStatus() }
        .sheet(isPresented: $subscriptionManager.showPaywall, onDismiss: {
            subscriptionManager.dismissPaywall()
        }) {
            PaywallView()
        }
        .sheet(isPresented: $subscriptionManager.showFeaturePreviewSheet, onDismiss: {
            subscriptionManager.dismissFeaturePreviewAndPresentPaywall()
        }) {
            if let content = subscriptionManager.featurePreviewContent {
                FeaturePreviewDisclaimerSheet(
                    titleKey: content.titleKey,
                    messageKey: content.messageKey,
                    accentColorName: content.accentColorName
                )
            }
        }
    }

    @ViewBuilder
    private var tabViewLegacy: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("tab_learn_title".localized(for: appLanguage), systemImage: "book.fill")
                }
                .tag(TabIdentifier.learn)
            ProgressTabView()
                .tabItem {
                    Label("tab_progress_title".localized(for: appLanguage), systemImage: "gauge.with.dots.needle.bottom.50percent")
                }
                .tag(TabIdentifier.progress)
            SettingsDashboardView()
                .tabItem {
                    Label("tab_settings_title".localized(for: appLanguage), systemImage: "gear")
                }
                .tag(TabIdentifier.settings)

            SearchTabView()
                .tabItem {
                    Label("tab_search_title".localized(for: appLanguage), systemImage: "magnifyingglass")
                }
                .tag(TabIdentifier.search)
        }
        .tint(Color.accentColor)
        .compactTabBarSpacing(0)
        .task { await SubscriptionManager.shared.refreshPremiumStatus() }
        .onChange(of: selectedTab) { _, _ in
            HapticManager.shared.selectionChanged()
        }
        .sheet(isPresented: $subscriptionManager.showPaywall, onDismiss: {
            subscriptionManager.dismissPaywall()
        }) {
            PaywallView()
        }
        .sheet(isPresented: $subscriptionManager.showFeaturePreviewSheet, onDismiss: {
            subscriptionManager.dismissFeaturePreviewAndPresentPaywall()
        }) {
            if let content = subscriptionManager.featurePreviewContent {
                FeaturePreviewDisclaimerSheet(
                    titleKey: content.titleKey,
                    messageKey: content.messageKey,
                    accentColorName: content.accentColorName
                )
            }
        }
    }
}

#Preview("Main View") {
    MainView()
        .environmentObject(LanguageManager())
        .environmentObject(StateManager.shared)
        .environmentObject(SoundManager.shared)
        .environmentObject(AppFlow())
        .environmentObject(SubscriptionManager.shared)
        .environmentObject(FavoritesManager.shared)
}
