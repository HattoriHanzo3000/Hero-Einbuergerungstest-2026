import SwiftUI

// MARK: - Progress Tab View
/// Progress tab: rounded header with mascot, then progress section (ring chart and stat cards) from main page.
struct ProgressTabView: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @StateObject private var viewModel: HomeViewModel = MainActor.assumeIsolated {
        HomeViewModel(statisticsProvider: HomeStatisticsService(), stateManager: StateManager.shared)
    }

    private var sectionSpacing: CGFloat { layoutMetrics.adaptive(LayoutMetrics.sectionSpacing) }

    var body: some View {
        VStack(spacing: 0) {
            progressHeaderSection

            if subscriptionManager.isPremium {
                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: sectionSpacing) {
                            Color.clear.frame(height: 0).id("scrollTop")
                            HomeStatisticsSection(statistics: viewModel.statistics)
                                .padding(.horizontal, layoutMetrics.adaptive(LayoutMetrics.headerHorizontalPadding))
                        }
                        .padding(.top, layoutMetrics.adaptive(12))
                        .padding(.bottom, layoutMetrics.adaptive(LayoutMetrics.footerPadding))
                        .frame(maxWidth: .infinity, alignment: .top)
                        .id(languageManager.currentAppLanguage)
                    }
                    .onAppear { proxy.scrollTo("scrollTop", anchor: .top) }
                }
            } else {
                progressGatePlaceholder
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .toolbar(.visible, for: .tabBar)
        .onAppear {
            viewModel.refreshStatistics()
        }
        .tabBarHidden(false)
    }

    /// Placeholder shown when user is not premium. Paywall is triggered on appear.
    private var progressGatePlaceholder: some View {
        VStack(spacing: layoutMetrics.adaptive(24)) {
            Spacer()
            Image(systemName: "chart.bar.fill")
                .font(.system(size: layoutMetrics.adaptive(56)))
                .foregroundStyle(.secondary)
                .symbolRenderingMode(.hierarchical)
            Text("progress_premium_gate_message".localized)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, layoutMetrics.adaptive(32))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Header Section (flat gradient, same as Home)
private extension ProgressTabView {
    var progressHeaderSection: some View {
        HomeHeader(
            readinessPercentage: viewModel.statistics.readinessPercentage,
            onPremiumTap: { subscriptionManager.presentPaywall() },
            useCard: false,
            mascotAssetBaseName: "MainChickFlipped"
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
    ProgressTabView()
        .environmentObject(LanguageManager())
        .environmentObject(SubscriptionManager.shared)
        .environmentObject(StateManager.shared)
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
