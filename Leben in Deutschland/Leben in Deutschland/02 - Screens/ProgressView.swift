import SwiftUI

// MARK: - Progress Tab View
/// Progress tab: rounded header with mascot, then progress section (ring chart and stat cards) from main page.
struct ProgressTabView: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var premiumManager: PremiumManager
    @StateObject private var viewModel: HomeViewModel = HomeViewModel()

    private var sectionSpacing: CGFloat { layoutMetrics.adaptive(LayoutMetrics.sectionSpacing) }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: sectionSpacing) {
                progressHeaderSection
                HomeStatisticsSection(statistics: viewModel.statistics)
                    .padding(.horizontal, layoutMetrics.adaptive(LayoutMetrics.headerHorizontalPadding))
            }
            .padding(.bottom, layoutMetrics.adaptive(LayoutMetrics.footerPadding))
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .toolbar(.visible, for: .tabBar)
        .onAppear {
            viewModel.refreshStatistics()
        }
        .tabBarHidden(false)
    }
}

// MARK: - Header Section
private extension ProgressTabView {
    var progressHeaderSection: some View {
        ScreenHeader(
            readinessPercentage: viewModel.statistics.readinessPercentage,
            onPremiumTap: { premiumManager.presentPaywall() },
            autoPlayInterval: nil,
            content: .readiness
        )
        .screenHeaderPadding(metrics: layoutMetrics)
    }
}

// MARK: - Preview
#Preview {
    ProgressTabView()
        .environmentObject(LanguageManager())
        .environmentObject(PremiumManager.shared)
        .environmentObject(StateManager.shared)
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
