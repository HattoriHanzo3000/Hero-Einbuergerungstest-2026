import SwiftData
import SwiftUI

// MARK: - Main View
/// Root tab navigation that hosts the primary app sections.
/// Mirrors B2's `MainView` role as the app-wide container with visible tab bar.
struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @AppStorage("appLanguage") private var appLanguage: String = LanguageManager.baseLanguageCode
    @State private var selectedTab: TabIdentifier = .learn
    @State private var sectionBeforeSearch: TabIdentifier = .learn
    /// Bumps when leaving search so TabView remounts and resyncs tab bar visibility (iPadOS 18 workaround).
    @State private var tabShellGeneration = 0
    @StateObject private var searchSession = SearchSessionStore()

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
        TabView(selection: $selectedTab) {
            Tab("tab_learn_title".localized(for: appLanguage), systemImage: "book.fill", value: TabIdentifier.learn) {
                HomeView()
            }
            .accessibilityHint("tab_learn_hint".localized(for: appLanguage))

            Tab("tab_progress_title".localized(for: appLanguage), systemImage: "gauge.with.dots.needle.bottom.50percent", value: TabIdentifier.progress) {
                CockpitView()
            }
            .accessibilityHint("tab_progress_hint".localized(for: appLanguage))

            Tab("tab_settings_title".localized(for: appLanguage), systemImage: "gear", value: TabIdentifier.settings) {
                SettingsDashboardView()
            }
            .accessibilityHint("tab_settings_hint".localized(for: appLanguage))

            Tab(value: TabIdentifier.search, role: .search) {
                SearchTabView(
                    selectedTab: $selectedTab,
                    sectionBeforeSearch: sectionBeforeSearch,
                    session: searchSession
                )
            } label: {
                Label("tab_search_title".localized(for: appLanguage), systemImage: "magnifyingglass")
            }
            .accessibilityHint("tab_search_hint".localized(for: appLanguage))
        }
        .id(tabShellGeneration)
        .modifier(TabShellTabBarChromeModifier(isSearchSelected: selectedTab == .search))
        .toolbar(.automatic, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .tint(Color.accentColor)
        .compactTabBarSpacing(0)
        .accessibilityLabel("main_tab_bar_accessibility_label".localized(for: appLanguage))
        .onAppear(perform: attachProgressPersistenceCoordinator)
        .task { await SubscriptionManager.shared.refreshProStatus() }
        .onChange(of: selectedTab) { oldValue, newValue in
            handleSelectedTabChange(from: oldValue, to: newValue)
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

    @ViewBuilder
    private var tabViewLegacy: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("tab_learn_title".localized(for: appLanguage), systemImage: "book.fill")
                }
                .tag(TabIdentifier.learn)
            CockpitView()
                .tabItem {
                    Label("tab_progress_title".localized(for: appLanguage), systemImage: "gauge.with.dots.needle.bottom.50percent")
                }
                .tag(TabIdentifier.progress)
            SettingsDashboardView()
                .tabItem {
                    Label("tab_settings_title".localized(for: appLanguage), systemImage: "gear")
                }
                .tag(TabIdentifier.settings)

            SearchTabView(
                selectedTab: $selectedTab,
                sectionBeforeSearch: sectionBeforeSearch,
                session: searchSession
            )
                .tabItem {
                    Label("tab_search_title".localized(for: appLanguage), systemImage: "magnifyingglass")
                }
                .tag(TabIdentifier.search)
        }
        .tint(Color.accentColor)
        .compactTabBarSpacing(0)
        .onAppear(perform: attachProgressPersistenceCoordinator)
        .task { await SubscriptionManager.shared.refreshProStatus() }
        .onChange(of: selectedTab) { oldValue, newValue in
            handleSelectedTabChange(from: oldValue, to: newValue)
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

    private func handleSelectedTabChange(from oldValue: TabIdentifier, to newValue: TabIdentifier) {
        HapticManager.shared.selectionChanged()
        if newValue == .search, oldValue != .search {
            sectionBeforeSearch = oldValue
        } else if newValue != .search {
            sectionBeforeSearch = newValue
            if oldValue == .search {
                tabShellGeneration += 1
                restoreTabBarAfterLeavingSearch()
            }
        }
    }

    private func restoreTabBarAfterLeavingSearch() {
        TabBarVisibility.restoreVisible()
    }

    private func attachProgressPersistenceCoordinator() {
        ProgressPersistenceCoordinator.shared.attach(modelContext: modelContext)
#if DEBUG
        if let federalState = LaunchConfiguration.consumePendingFederalStateReload() {
            ProgressPersistenceCoordinator.shared.reloadForFederalState(federalState)
        }
#endif
    }
}

#Preview("Main View") {
    MainView()
        .modelContainer(try! SwiftDataModelContainerFactory.makePreviewContainer())
        .environmentObject(LanguageManager())
        .environmentObject(StateManager.shared)
        .environmentObject(SoundManager.shared)
        .environmentObject(AppFlow())
        .environmentObject(SubscriptionManager.shared)
        .environmentObject(FavoritesManager.shared)
}
