import SwiftUI

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
}

// MARK: - Option 1: UIKit-based Instant Tab Bar Control
/// Uses UIKit API for instant tab bar visibility updates (no delay)
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
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let tabBarController = findTabBarController(in: window.rootViewController) {
                tabBarController.tabBar.isHidden = hidden
            }
        }
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

extension View {
    /// Instantly hides/shows tab bar using UIKit API (no animation delay)
    func tabBarHidden(_ hidden: Bool) -> some View {
        modifier(TabBarVisibilityModifier(isHidden: hidden))
    }
}

// MARK: - Option 2: PreferenceKey-based Approach
struct TabBarVisibilityKey: PreferenceKey {
    static var defaultValue: Bool = false // false = visible, true = hidden
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

extension View {
    /// Sets tab bar visibility preference
    func tabBarVisibility(_ hidden: Bool) -> some View {
        preference(key: TabBarVisibilityKey.self, value: hidden)
    }
    
    /// Reads tab bar visibility preference and applies UIKit update
    func onTabBarVisibilityChange(_ action: @escaping (Bool) -> Void) -> some View {
        onPreferenceChange(TabBarVisibilityKey.self, perform: action)
    }
}
