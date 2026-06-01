import SwiftUI

// MARK: - Cockpit View
/// Cockpit tab: rounded header with mascot, then progress section (ring chart and stat cards) from main page.
struct CockpitView: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @StateObject private var viewModel: HomeViewModel = MainActor.assumeIsolated {
        #if DEBUG
        HomeViewModel(statisticsProvider: DebugAwareHomeStatisticsProvider(), stateManager: StateManager.shared)
        #else
        HomeViewModel(statisticsProvider: HomeStatisticsService(), stateManager: StateManager.shared)
        #endif
    }
    @State private var showMoreFromHeroSheet = false

    private var sectionSpacing: CGFloat { layoutMetrics.adaptive(LayoutMetrics.sectionSpacing) }

    var body: some View {
        VStack(spacing: 0) {
            progressHeaderSection

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: sectionSpacing) {
                        Color.clear.frame(height: 0).id("scrollTop")
                        CockpitProgressSection(statistics: viewModel.statistics)
                        CockpitMoreFromHeroSection(showSheet: $showMoreFromHeroSheet)
                    }
                    .padding(.top, layoutMetrics.adaptive(12))
                    .padding(.bottom, layoutMetrics.adaptive(LayoutMetrics.footerPadding))
                    .frame(maxWidth: .infinity, alignment: .top)
                    .id(languageManager.currentAppLanguage)
                }
                .onAppear { proxy.scrollTo("scrollTop", anchor: .top) }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .restoresTabBarOnAppear()
        .onAppear {
            viewModel.refreshStatistics()
        }
        .sheet(isPresented: $showMoreFromHeroSheet) {
            AdvertisementView()
        }
    }
}

// MARK: - Header Section (flat gradient, same as Home)
private extension CockpitView {
    var progressHeaderSection: some View {
        HomeHeader(
            readinessPercentage: viewModel.statistics.readinessPercentage,
            isProUser: subscriptionManager.effectiveIsPro,
            useCard: false,
            mascotHorizontallyFlipped: true,
            alternatingEnabled: true
        )
        .padding(.horizontal, layoutMetrics.adaptive(16))
        .padding(.bottom, layoutMetrics.adaptive(12))
        .background(
            Rectangle()
                .fill(LiquidGlassGradient.blue.screenBackground)
                .ignoresSafeArea(edges: .top)
        )
    }
}

// MARK: - Preview
#Preview {
    CockpitView()
        .environmentObject(LanguageManager())
        .environmentObject(SubscriptionManager.shared)
        .environmentObject(StateManager.shared)
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
