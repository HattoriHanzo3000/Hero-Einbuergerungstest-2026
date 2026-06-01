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

    /// SwiftUI + UIKit restore after search tab or pushed screens hide the tab bar.
    func restoresTabBarOnAppear() -> some View {
        modifier(RestoresTabBarOnAppearModifier())
    }
}

private struct RestoresTabBarOnAppearModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbar(.visible, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .onAppear {
                TabBarVisibility.restoreVisible()
            }
    }
}

extension View {

    /// Syncs UIKit tab bar visibility with push/pop transitions.
    func hidesBottomBarWhenPushed(_ hides: Bool) -> some View {
        background(HidesBottomBarWhenPushedBridge(hidesBottomBar: hides))
    }

    /// Hides tab bar when a learning/question-card screen is pushed; keeps the system navigation bar.
    func hidesLearningChrome() -> some View {
        toolbar(.hidden, for: .tabBar)
            .hidesBottomBarWhenPushed(true)
    }

    /// Disables the navigation stack edge-swipe back gesture (UIKit interactive pop).
    func navigationInteractivePopDisabled(_ disabled: Bool = true) -> some View {
        background(NavigationInteractivePopBridge(isDisabled: disabled))
    }
}

// MARK: - Interactive Pop Gesture
private struct NavigationInteractivePopBridge: UIViewControllerRepresentable {
    var isDisabled: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        controller.view.isUserInteractionEnabled = false
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        apply(to: uiViewController)
    }

    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: ()) {
        uiViewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    private func apply(to bridge: UIViewController) {
        let enabled = !isDisabled
        func setGesture(on navigationController: UINavigationController?) {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = enabled
        }

        if let navigationController = bridge.navigationController {
            setGesture(on: navigationController)
            return
        }
        DispatchQueue.main.async {
            setGesture(on: bridge.navigationController)
        }
    }
}

// MARK: - UIKit Tab Bar Visibility
enum TabBarVisibility {
    /// Restores the tab bar after search-tab chrome or navigation push left it hidden (common on iPad).
    static func restoreVisible() {
        setHidden(false)
        resetNavigationBarsHidingTabBar()
        unhideAllTabBarViews(hidden: false)
        scheduleRestoreRetries()
    }

    static func setHidden(_ hidden: Bool) {
        DispatchQueue.main.async {
            applyHidden(hidden)
            if !hidden {
                resetNavigationBarsHidingTabBar()
                unhideAllTabBarViews(hidden: false)
            }
        }
    }

    private static func scheduleRestoreRetries() {
        for delay in [0.15, 0.35, 0.6] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                applyHidden(false)
                resetNavigationBarsHidingTabBar()
                unhideAllTabBarViews(hidden: false)
            }
        }
    }

    private static func applyHidden(_ hidden: Bool) {
        for window in keyWindows() {
            guard let tabBarController = UITabBarController.find(in: window.rootViewController) else { continue }
            let tabBar = tabBarController.tabBar
            tabBar.layer.removeAllAnimations()
            tabBar.transform = .identity
            tabBar.alpha = 1
            tabBar.isHidden = hidden
        }
    }

    private static func keyWindows() -> [UIWindow] {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let keyed = scenes.flatMap(\.windows).filter(\.isKeyWindow)
        if !keyed.isEmpty { return keyed }
        return scenes.flatMap(\.windows)
    }

    private static func unhideAllTabBarViews(hidden: Bool) {
        for window in keyWindows() {
            applyTabBarVisibility(in: window, hidden: hidden)
        }
    }

    private static func applyTabBarVisibility(in view: UIView, hidden: Bool) {
        if let tabBar = view as? UITabBar {
            tabBar.layer.removeAllAnimations()
            tabBar.transform = .identity
            tabBar.alpha = 1
            tabBar.isHidden = hidden
        }
        view.subviews.forEach { applyTabBarVisibility(in: $0, hidden: hidden) }
    }

    private static func resetNavigationBarsHidingTabBar() {
        for window in keyWindows() {
            resetHidesBottomBarWhenPushed(in: window.rootViewController)
        }
    }

    private static func resetHidesBottomBarWhenPushed(in viewController: UIViewController?) {
        guard let viewController else { return }

        if let navigationController = viewController as? UINavigationController {
            navigationController.viewControllers.forEach { $0.hidesBottomBarWhenPushed = false }
        }

        viewController.children.forEach { resetHidesBottomBarWhenPushed(in: $0) }
        resetHidesBottomBarWhenPushed(in: viewController.presentedViewController)
    }
}

// MARK: - Tab Shell Chrome (iOS 18+ search tab)
struct TabShellTabBarChromeModifier: ViewModifier {
    let isSearchSelected: Bool

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.tabBarMinimizeBehavior(isSearchSelected ? .automatic : .never)
        } else {
            content
        }
    }
}

// MARK: - Tab Bar Restore Host
/// Keeps forcing tab bar visible while a non-search tab is selected (works around iPadOS 18 search-tab bugs).
struct TabBarRestoreHost: UIViewControllerRepresentable {
    var isActive: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.isUserInteractionEnabled = false
        controller.view.backgroundColor = .clear
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard isActive else { return }
        TabBarVisibility.restoreVisible()
    }
}

// MARK: - Legacy UIKit Tab Bar Visibility
struct TabBarVisibilityModifier: ViewModifier {
    let isHidden: Bool

    func body(content: Content) -> some View {
        content
            .onAppear {
                TabBarVisibility.setHidden(isHidden)
            }
            .onChange(of: isHidden) { _, newValue in
                TabBarVisibility.setHidden(newValue)
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
