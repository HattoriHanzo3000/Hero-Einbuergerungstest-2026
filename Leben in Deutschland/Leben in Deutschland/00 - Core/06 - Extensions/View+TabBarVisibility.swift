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

// MARK: - Option 1: UIKit-based Tab Bar Control with Slide Animation
/// Hides tab bar instantly; shows it with a slide-up-from-bottom animation when returning to root.
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
            
            if hidden {
                // Animate hiding: slide down smoothly
                // Only animate if tab bar is currently visible
                guard !tabBar.isHidden && tabBar.alpha > 0 else {
                    tabBar.isHidden = true
                    return
                }
                
                let height = tabBar.bounds.height > 0 ? tabBar.bounds.height : (tabBar.frame.height > 0 ? tabBar.frame.height : 49)
                
                UIView.animate(
                    withDuration: 0.35,
                    delay: 0,
                    usingSpringWithDamping: 0.9,
                    initialSpringVelocity: 0.3,
                    options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseIn],
                    animations: {
                        tabBar.transform = CGAffineTransform(translationX: 0, y: height)
                        tabBar.alpha = 0
                    },
                    completion: { _ in
                        tabBar.isHidden = true
                        tabBar.transform = .identity
                        tabBar.alpha = 1
                    }
                )
            } else {
                // Only animate if tab bar is currently hidden or off-screen (e.g. after returning from pushed view)
                guard tabBar.isHidden || tabBar.alpha < 1 || tabBar.transform != .identity else { return }
                
                // Animate showing: slide up from bottom
                tabBar.isHidden = false
                tabBar.alpha = 0
                
                // Get the actual height - use frame if bounds is 0
                let height = tabBar.bounds.height > 0 ? tabBar.bounds.height : (tabBar.frame.height > 0 ? tabBar.frame.height : 49)
                
                // Set initial position off-screen
                tabBar.transform = CGAffineTransform(translationX: 0, y: height)
                
                // Wait for next run loop to ensure tab bar is laid out, then animate
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Double-check tab bar is still visible and get updated height
                    let currentHeight = tabBar.bounds.height > 0 ? tabBar.bounds.height : (tabBar.frame.height > 0 ? tabBar.frame.height : 49)
                    
                    // Ensure it starts from off-screen position
                    tabBar.transform = CGAffineTransform(translationX: 0, y: currentHeight)
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
            }
        }
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
