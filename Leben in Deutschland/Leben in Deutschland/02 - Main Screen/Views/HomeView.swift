import SwiftUI

// MARK: - Home View
/// Displays the primary landing surface with the federal state hero header.
struct HomeView: View {
    @EnvironmentObject private var stateManager: StateManager
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var premiumManager: PremiumManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    @StateObject private var viewModel: HomeViewModel
    @StateObject private var ratingManager = AppRatingManager.shared
    @State private var router = AppRouter()
    @State private var showDialog = false
    @State private var savedTestDate: Date? = OnboardingPreferences.shared.testDate
    @State private var showRatingPrompt = false
    
    /// Spacing between header and section (matches Progress tab).
    private var sectionSpacing: CGFloat { layoutMetrics.adaptive(28) }
    private var footerPadding: CGFloat { layoutMetrics.adaptive(36) }
    
    init(viewModel: HomeViewModel = HomeViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack(path: $router.navigationPath) {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: sectionSpacing) {
                    MainHeaderContent(
                        readinessPercentage: viewModel.statistics.readinessPercentage,
                        showDialog: $showDialog,
                        savedTestDate: $savedTestDate,
                        onPremiumTap: { premiumManager.presentPaywall() }
                    )
                    .padding(.horizontal, layoutMetrics.adaptive(20))
                    .padding(.top, layoutMetrics.adaptive(8))
                    .padding(.bottom, layoutMetrics.adaptive(4))

                    HomeLearnSection()
                        .padding(.horizontal, layoutMetrics.adaptive(20))
                }
                .padding(.bottom, footerPadding + geometry.safeAreaInsets.bottom)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .frame(width: geometry.size.width)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground).ignoresSafeArea())
            .navigationDestination(for: AppRouter.Destination.self) { destination in
                destinationView(for: destination)
            }
        .onAppear {
            handleOnAppear()
            // Animate tab bar slide-up when returning to home view
            // Delay to ensure navigation transition completes first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animateTabBarSlideUp()
            }
        }
        .id(stateManager.selectedState ?? "no_state")
        }
        .environment(router)
        .overlay {
            if showRatingPrompt {
                AppRatingPromptView(
                    ratingManager: ratingManager,
                    onRateNow: {
                        ratingManager.userChoseToRate()
                        showRatingPrompt = false
                    },
                    onAskLater: {
                        ratingManager.userChoseLater()
                        showRatingPrompt = false
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.9)))
                .zIndex(1000)
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: AppRouter.Destination) -> some View {
        switch destination {
        case .categories:
            CategoriesView()
                .environmentObject(languageManager)
        case .learning(let subcategoryName, let categoryName):
            LearningDestinationView(
                subcategoryName: subcategoryName,
                categoryName: categoryName
            )
            .environmentObject(languageManager)
        case .favorites:
            FavoritesView()
                .environmentObject(languageManager)
        case .spacedRepetition:
            SpacedRepetitionView()
                .environmentObject(languageManager)
        case .testCountdown:
            TestCountdownView {
                router.push(.testSimulation)
            }
            .environmentObject(languageManager)
            .environmentObject(stateManager)
        case .testSimulation:
            TestSessionView()
                .environmentObject(languageManager)
                .environmentObject(FavoritesManager.shared)
                .environmentObject(stateManager)
        case .settings:
            SettingsDashboardView()
        case .premium:
            PremiumHubView()
                .environmentObject(languageManager)
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView(
        viewModel: HomeViewModel(
            statisticsProvider: PreviewHomeStatisticsProvider()
        )
    )
        .environmentObject(LanguageManager())
        .environmentObject(StateManager.shared)
        .environmentObject(PremiumManager.shared)
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

// MARK: - Private Helpers
private extension HomeView {
    func animateTabBarSlideUp() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let tabBarController = findTabBarController(in: window.rootViewController) else { return }
        let tabBar = tabBarController.tabBar
        
        // Only animate if tab bar is currently hidden or off-screen
        guard tabBar.isHidden || tabBar.alpha < 1 || tabBar.transform != .identity else { return }
        
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
    
    func animateTabBarSlideDown() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let tabBarController = findTabBarController(in: window.rootViewController) else { return }
        let tabBar = tabBarController.tabBar
        
        // Only animate if tab bar is currently visible
        guard !tabBar.isHidden && tabBar.alpha > 0 else { return }
        
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
    }
    
    func findTabBarController(in viewController: UIViewController?) -> UITabBarController? {
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
    
    func handleOnAppear() {
        savedTestDate = OnboardingPreferences.shared.testDate
        viewModel.refreshStatistics()
        
        // Record app launch for rating manager
        ratingManager.recordAppLaunch()
        
        // Show eagle dialog if not already showing
        guard showDialog == false else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                showDialog = true
            }
        }
        
        // Check if we should show rating prompt (after a delay to not interrupt user)
        // Wait longer to ensure eagle dialog has appeared first
        if ratingManager.shouldPromptForRating() && !showRatingPrompt {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                // Only show if eagle dialog is not currently showing
                if !showDialog {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showRatingPrompt = true
                    }
                }
            }
        }
    }
}

// MARK: - Preview Provider
private struct PreviewHomeStatisticsProvider: HomeStatisticsProviding {
    func loadStatistics() -> HomeStatisticsModel {
        HomeStatisticsModel(
            readinessPercentage: 72,
            familiar: 86,
            reinforced: 54,
            mastered: 158,
            expert: 12,
            totalQuestions: LayoutMetrics.totalFederalQuestions
        )
    }
}
