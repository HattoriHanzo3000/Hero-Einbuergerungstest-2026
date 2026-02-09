import SwiftUI
import UIKit

// MARK: - Main Tab View
/// Root tab navigation that hosts the primary app sections.
/// Four tabs: Learn, Test, Progress, Settings.
struct MainTabView: View {
    @EnvironmentObject private var premiumManager: PremiumManager
    
    // MARK: - Tab Identifier
    enum Tab: Hashable {
        case learn
        case test
        case progress
        case settings
    }
    
    // MARK: - State
    @State private var selectedTab: Tab = .learn
    
    /// Scale factor for tab bar icons (system default is ~1; we use 1.5 for clearer tap targets).
    private static let tabBarIconScale: CGFloat = 1.5
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label {
                        Text("tab_learn_title".localized)
                    } icon: {
                        Image(systemName: "book.fill")
                    }
                }
                .tag(Tab.learn)
                .accessibilityHint("tab_learn_hint".localized)
            
            TestTabView()
                .tabItem {
                    Label {
                        Text("tab_test_title".localized)
                    } icon: {
                        Image(systemName: "checkmark.seal.fill")
                    }
                }
                .tag(Tab.test)
                .accessibilityHint("tab_test_hint".localized)
            
            ProgressTabView()
                .tabItem {
                    Label {
                        Text("tab_progress_title".localized)
                    } icon: {
                        Image(systemName: "chart.bar.fill")
                    }
                }
                .tag(Tab.progress)
                .accessibilityHint("tab_progress_hint".localized)
            
            SettingsDashboardView()
                .tabItem {
                    Label {
                        Text("tab_settings_title".localized)
                    } icon: {
                        Image(systemName: "gear")
                    }
                }
                .tag(Tab.settings)
                .accessibilityHint("tab_settings_hint".localized)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear.frame(height: 12)
        }
        .tint(Color("AppBlueLagoon"))
        .onAppear {
            Self.applyTabBarIconScale()
        }
        .accessibilityLabel("main_tab_bar_accessibility_label".localized)
        .sheet(isPresented: Binding(
            get: { premiumManager.showPaywall },
            set: { premiumManager.showPaywall = $0 }
        ), onDismiss: {
            premiumManager.showPaywall = false
        }) {
            PaywallView()
                .environmentObject(premiumManager)
        }
    }
    
    /// Applies a larger scale to tab bar item icons by finding the tab bar in the window hierarchy.
    private static func applyTabBarIconScale() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }),
                  let tabBarController = findTabBarController(in: window.rootViewController) else { return }
            let tabBar = tabBarController.tabBar
            let scale = CGAffineTransform(scaleX: tabBarIconScale, y: tabBarIconScale)
            for button in tabBar.subviews {
                for child in button.subviews {
                    if let imageView = child as? UIImageView {
                        imageView.transform = scale
                    }
                }
            }
        }
    }
    
    private static func findTabBarController(in viewController: UIViewController?) -> UITabBarController? {
        guard let viewController = viewController else { return nil }
        if let tbc = viewController as? UITabBarController { return tbc }
        for child in viewController.children {
            if let tbc = findTabBarController(in: child) { return tbc }
        }
        if let presented = viewController.presentedViewController {
            return findTabBarController(in: presented)
        }
        return nil
    }
}

// MARK: - Preview
// MARK: - Preview
#Preview("Main Tab View") {
    MainTabView()
        .environmentObject(LanguageManager())
        .environmentObject(StateManager.shared)
        .environmentObject(SoundManager.shared)
        .environmentObject(AppFlow())
        .environmentObject(PremiumManager.shared)
        .environmentObject(FavoritesManager.shared)
}

