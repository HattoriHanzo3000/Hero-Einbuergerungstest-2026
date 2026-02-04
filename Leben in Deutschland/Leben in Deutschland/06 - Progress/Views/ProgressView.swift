import SwiftUI

// MARK: - Progress Tab View
/// Progress tab: rounded header with mascot, then progress section (ring chart and stat cards) from main page.
struct ProgressTabView: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
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
            // Ensure tab bar is visible
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showTabBar()
            }
        }
    }
}

// MARK: - Header Section (same rounded style as question card)
private extension ProgressTabView {
    var progressHeaderSection: some View {
        VStack(alignment: .leading, spacing: layoutMetrics.adaptive(16)) {
            MainMascotView(
                messageKey: "eagle_desc_chick",
                messageParameters: ["0"],
                leadingMessage: nil,
                showDialog: $showDialog,
                autoPlayInterval: nil,
                hideBubble: true,
                plainTextColor: .white
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, layoutMetrics.adaptive(18))
        .padding(.horizontal, layoutMetrics.adaptive(20))
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .background(liquidGlassBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: layoutMetrics.adaptive(32),
                style: .continuous
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: layoutMetrics.adaptive(32),
                style: .continuous
            )
            .stroke(
                LinearGradient(
                    colors: [
                        .white.opacity(0.4),
                        .white.opacity(0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 0.8
            )
        )
        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
        .padding(.horizontal, layoutMetrics.adaptive(20))
        .padding(.top, layoutMetrics.adaptive(8))
        .padding(.bottom, layoutMetrics.adaptive(4))
    }

    var liquidGlassBackground: some View {
        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(32), style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color("AppBlueLagoon").opacity(0.9),
                        Color("AppBlueLagoon").opacity(0.65),
                        Color("AppCaribean").opacity(0.45)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.20),
                        Color.white.opacity(0.05),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(38), style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.45),
                                Color.white.opacity(0.12)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.6
                    )
            )
            .background(
                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(38), style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
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
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
