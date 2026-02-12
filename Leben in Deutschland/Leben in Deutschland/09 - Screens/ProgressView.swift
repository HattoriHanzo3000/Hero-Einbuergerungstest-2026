import SwiftUI

// MARK: - Progress Tab View
/// Progress tab: rounded header with mascot, then progress section (ring chart and stat cards) from main page.
struct ProgressTabView: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var premiumManager: PremiumManager
    @StateObject private var viewModel: HomeViewModel = HomeViewModel()
    @State private var showDialog = false

    private var sectionSpacing: CGFloat { layoutMetrics.adaptive(28) }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: sectionSpacing) {
                progressHeaderSection
                HomeStatisticsSection(statistics: viewModel.statistics)
                    .padding(.horizontal, layoutMetrics.adaptive(20))
            }
            .padding(.bottom, layoutMetrics.adaptive(36))
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .toolbar(.visible, for: .tabBar)
        .onAppear {
            viewModel.refreshStatistics()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showTabBar()
            }
        }
    }
}

// MARK: - Header Section
private extension ProgressTabView {
    var progressHeaderSection: some View {
        ScreenHeader(
            readinessPercentage: viewModel.statistics.readinessPercentage,
            showDialog: $showDialog,
            onPremiumTap: { premiumManager.presentPaywall() },
            autoPlayInterval: nil,
            content: .readiness
        )
        .padding(.horizontal, layoutMetrics.adaptive(20))
        .padding(.top, layoutMetrics.adaptive(8))
        .padding(.bottom, layoutMetrics.adaptive(4))
    }
    
    private func showTabBar() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let tabBarController = findTabBarController(in: window.rootViewController) else { return }
        let tabBar = tabBarController.tabBar
        
        guard tabBar.isHidden else { return }
        
        let height = tabBar.bounds.height > 0 ? tabBar.bounds.height : (tabBar.frame.height > 0 ? tabBar.frame.height : 49)
        
        tabBar.isHidden = false
        tabBar.transform = CGAffineTransform(translationX: 0, y: height)
        tabBar.alpha = 0
        
        UIView.animate(
            withDuration: 0.45,
            delay: 0,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.4,
            options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseOut],
            animations: {
                tabBar.transform = .identity
                tabBar.alpha = 1
            }
        )
    }
    
    private func findTabBarController(in viewController: UIViewController?) -> UITabBarController? {
        guard let viewController = viewController else { return nil }
        
        if let tabBarController = viewController as? UITabBarController {
            return tabBarController
        }
        
        for child in viewController.children {
            if let tabBarController = findTabBarController(in: child) {
                return tabBarController
            }
        }
        
        if let presented = viewController.presentedViewController {
            return findTabBarController(in: presented)
        }
        
        return nil
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
