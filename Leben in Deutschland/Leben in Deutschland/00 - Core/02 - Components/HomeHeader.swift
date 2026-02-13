import SwiftUI

// MARK: - Home Header
/// Home screen header: mascot + state title + slogan. Uses shared ScreenHeaderCard.
struct HomeHeader: View {
    let readinessPercentage: Int
    var onPremiumTap: (() -> Void)?

    @EnvironmentObject private var stateManager: StateManager

    var body: some View {
        let content: ScreenHeaderCardContent = stateManager.selectedState.map { .state(stateName: $0) } ?? .readiness
        return ScreenHeaderCard(
            readinessPercentage: readinessPercentage,
            onPremiumTap: onPremiumTap,
            autoPlayInterval: 60,
            content: content
        )
    }
}

// MARK: - Preview
#Preview {
    HomeHeader(
        readinessPercentage: 72,
        onPremiumTap: {
            print("Premium tapped")
        }
    )
    .environmentObject(LanguageManager())
    .environmentObject(StateManager.shared)
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
