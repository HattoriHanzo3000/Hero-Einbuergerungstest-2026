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
    @State private var showRatingPrompt = false
    
    private var sectionSpacing: CGFloat { layoutMetrics.adaptive(LayoutMetrics.sectionSpacing) }
    private var footerPadding: CGFloat { layoutMetrics.adaptive(LayoutMetrics.footerPadding) }
    
    init(viewModel: HomeViewModel = HomeViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack(path: $router.navigationPath) {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HomeHeader(
                    readinessPercentage: viewModel.statistics.readinessPercentage,
                    onPremiumTap: { premiumManager.presentPaywall() },
                    useCard: false
                )
                .padding(.horizontal, layoutMetrics.adaptive(16))
                .padding(.bottom, layoutMetrics.adaptive(12))
                .background(
                    Rectangle()
                        .fill(LiquidGlassGradient.blue.screenBackground)
                        .ignoresSafeArea(edges: .top)
                )

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: sectionSpacing) {
                        HomeLearnOptionsSection()
                            .padding(.horizontal, layoutMetrics.adaptive(LayoutMetrics.headerHorizontalPadding))
                    }
                    .padding(.top, layoutMetrics.adaptive(12))
                    .padding(.bottom, footerPadding + geometry.safeAreaInsets.bottom)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .id(languageManager.currentAppLanguage)
                }
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
        }
        .tabBarHidden(false)
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
    func handleOnAppear() {
        viewModel.refreshStatistics()
        
        // Record app launch for rating manager
        ratingManager.recordAppLaunch()
        
        // Show rating prompt after a delay to not interrupt user on first load
        if ratingManager.shouldPromptForRating() && !showRatingPrompt {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showRatingPrompt = true
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
