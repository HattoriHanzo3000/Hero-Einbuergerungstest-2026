import SwiftUI

// MARK: - Main Header Content
/// Home screen header: mascot + state title + slogan. Uses shared ScreenHeader.
struct MainHeaderContent: View {
    let readinessPercentage: Int
    @Binding var showDialog: Bool
    var onPremiumTap: (() -> Void)?

    @EnvironmentObject private var stateManager: StateManager

    var body: some View {
        let content: ScreenHeaderContent = stateManager.selectedState.map { .state(stateName: $0) } ?? .readiness
        return ScreenHeader(
            readinessPercentage: readinessPercentage,
            showDialog: $showDialog,
            leadingMessage: nil,
            onPremiumTap: onPremiumTap,
            autoPlayInterval: 60,
            content: content
        )
    }
}

// MARK: - Preview
#Preview {
    MainHeaderContent(
        readinessPercentage: 72,
        showDialog: .constant(true),
        onPremiumTap: {
            print("Premium tapped")
        }
    )
    .environmentObject(LanguageManager())
    .environmentObject(StateManager.shared)
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
