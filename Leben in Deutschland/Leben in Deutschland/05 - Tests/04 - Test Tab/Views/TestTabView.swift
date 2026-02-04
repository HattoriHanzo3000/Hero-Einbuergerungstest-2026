//
//  TestTabView.swift
//  Leben in Deutschland
//
//  Test tab view with Take a Test option display
//

import SwiftUI

struct TestTabView: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager
    @StateObject private var headerViewModel = HomeViewModel()
    @State private var showDialog = false
    @State private var savedTestDate: Date? = OnboardingPreferences.shared.testDate
    @State private var router = AppRouter()
    
    private var verticalSpacing: CGFloat { layoutMetrics.adaptive(28) }
    private var tabBarHeight: CGFloat { 49 }
    
    private var testOption: LearnOptionModel {
        LearnOptionModel(
            titleKey: "learn_option_test_title",
            descriptionKey: "learn_option_test_description",
            iconSystemName: "checkmark.seal",
            palette: LearnOptionPalette(
                gradientColors: [
                    Color("AppOrange"),
                    Color(red: 0.77, green: 0.21, blue: 0.12)
                ],
                accentColor: Color("AppOrange")
            )
        )
    }
    
    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: verticalSpacing) {
                    TestHeaderContent(
                        readinessPercentage: headerViewModel.statistics.readinessPercentage,
                        showDialog: $showDialog,
                        savedTestDate: $savedTestDate
                    )
                    .padding(.horizontal, layoutMetrics.adaptive(20))
                    .padding(.top, layoutMetrics.adaptive(8))
                    .padding(.bottom, layoutMetrics.adaptive(4))

                    SectionContainer(title: "learn_option_test_title", spacing: layoutMetrics.adaptive(40)) {
                        VStack(spacing: layoutMetrics.adaptive(40)) {
                            Button {
                                HapticManager.shared.lightImpact()
                                router.push(.testCountdown)
                            } label: {
                                TestOptionIconView(
                                    icon: "checkmark.seal",
                                    color: Color("AppBlueLagoon"),
                                    layoutMetrics: layoutMetrics
                                )
                            }
                            .buttonStyle(BouncyScaleButtonStyle())
                            .accessibilityLabel("learn_option_test_title".localized)
                            .accessibilityHint("learn_option_test_description".localized)

                            Text(testOption.descriptionKey.localized)
                                .font(.system(.body, design: .rounded).weight(.semibold))
                                .foregroundColor(Color(.secondaryLabel))
                                .lineSpacing(4)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .accessibilityLabel(testOption.descriptionKey.localized)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
                    .padding(.horizontal, layoutMetrics.adaptive(20))
                }
                .padding(.bottom, layoutMetrics.adaptive(36))
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .navigationDestination(for: AppRouter.Destination.self) { destination in
                destinationView(for: destination)
            }
        }
        .toolbar(.visible, for: .tabBar)
        .environment(router)
        .onAppear {
            savedTestDate = OnboardingPreferences.shared.testDate
            headerViewModel.refreshStatistics()
            triggerDialog()
            // Ensure tab bar is visible
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showTabBar()
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: AppRouter.Destination) -> some View {
        switch destination {
        case .testCountdown:
            TestCountdownView {
                router.push(.testSimulation)
            }
            .environmentObject(languageManager)
            .environmentObject(StateManager.shared)
        case .testSimulation:
            TestSessionView()
                .environmentObject(languageManager)
                .environmentObject(FavoritesManager.shared)
                .environmentObject(StateManager.shared)
        default:
            EmptyView()
        }
    }
    
    private func triggerDialog() {
        guard !showDialog else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                showDialog = true
            }
        }
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

// MARK: - Test Option Icon View (colored square, matches Home learn section style)
private struct TestOptionIconView: View {
    let icon: String
    let color: Color
    let layoutMetrics: LayoutMetrics

    @State private var pulse = false

    private var boxSize: CGFloat { layoutMetrics.adaptive(68) * 1.5 }
    private var cornerRadius: CGFloat { layoutMetrics.adaptive(28) }
    private var iconSize: CGFloat { layoutMetrics.adaptive(56) }

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: iconSize, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: boxSize, height: boxSize)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(color)
            )
            .scaleEffect(pulse ? 1.04 : 0.96)
            .animation(
                .easeInOut(duration: 1.8).repeatForever(autoreverses: true),
                value: pulse
            )
            .onAppear {
                pulse = true
            }
    }
}

// MARK: - Bouncy Scale Button Style (matches Home learn section)
private struct BouncyScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview("Test Tab View") {
    TestTabView()
        .environmentObject(LanguageManager())
        .environmentObject(StateManager.shared)
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
