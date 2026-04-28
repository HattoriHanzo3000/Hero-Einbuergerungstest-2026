import SwiftUI
import UIKit

private struct HidesBottomBarWhenPushedBridge: UIViewControllerRepresentable {
    var hidesBottomBar: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        controller.view.isUserInteractionEnabled = false
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        applyHidesBottomBarWhenPushed(from: uiViewController)
    }

    private func applyHidesBottomBarWhenPushed(from bridge: UIViewController) {
        func targetHost() -> UIViewController? {
            var current: UIViewController? = bridge.parent
            while let vc = current {
                let className = NSStringFromClass(type(of: vc))
                if className.contains("UIHostingController") {
                    return vc
                }
                current = vc.parent
            }
            return bridge.parent
        }

        func assign(to host: UIViewController) {
            guard host.hidesBottomBarWhenPushed != hidesBottomBar else { return }
            host.hidesBottomBarWhenPushed = hidesBottomBar
        }

        if let host = targetHost() {
            assign(to: host)
            return
        }
        DispatchQueue.main.async {
            if let host = targetHost() {
                assign(to: host)
            }
        }
    }
}

// MARK: - Tab Bar Visibility Helpers
extension View {
    /// Hides the tab bar when this view is presented in a navigation stack hosted inside a TabView.
    func hidesTabBar() -> some View {
        toolbar(.hidden, for: .tabBar)
    }
    
    /// Shows the tab bar when this view is presented in a navigation stack hosted inside a TabView.
    func showsTabBar() -> some View {
        toolbar(.visible, for: .tabBar)
    }

    /// Syncs UIKit tab bar visibility with push/pop transitions.
    func hidesBottomBarWhenPushed(_ hides: Bool) -> some View {
        background(HidesBottomBarWhenPushedBridge(hidesBottomBar: hides))
    }

    /// Unified immersive chrome for learning/question-card flows.
    func hidesLearningChrome() -> some View {
        navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .toolbar(.hidden, for: .tabBar)
            .hidesBottomBarWhenPushed(true)
    }
}

// MARK: - Legacy UIKit Tab Bar Visibility
struct TabBarVisibilityModifier: ViewModifier {
    let isHidden: Bool
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                updateTabBarVisibility(hidden: isHidden)
            }
            .onChange(of: isHidden) { _, newValue in
                updateTabBarVisibility(hidden: newValue)
            }
    }
    
    private func updateTabBarVisibility(hidden: Bool) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let tabBarController = UITabBarController.find(in: window.rootViewController) else { return }
            let tabBar = tabBarController.tabBar
            tabBar.layer.removeAllAnimations()
            tabBar.transform = .identity
            tabBar.alpha = 1
            tabBar.isHidden = hidden
        }
    }
}

extension View {
    /// Instantly hides/shows tab bar using UIKit API (no animation delay)
    func tabBarHidden(_ hidden: Bool) -> some View {
        modifier(TabBarVisibilityModifier(isHidden: hidden))
    }

    /// Reduces spacing between tab bar items for a more compact layout.
    func compactTabBarSpacing(_ spacing: CGFloat = 0) -> some View {
        modifier(CompactTabBarSpacingModifier(spacing: spacing))
    }
}

// MARK: - Compact Tab Bar Spacing
private struct CompactTabBarSpacingModifier: ViewModifier {
    let spacing: CGFloat

    func body(content: Content) -> some View {
        content
            .onAppear { applySpacing() }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                applySpacing()
            }
    }

    private func applySpacing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let tabBarController = UITabBarController.find(in: window.rootViewController) else { return }
            tabBarController.tabBar.itemSpacing = spacing
        }
    }
}
