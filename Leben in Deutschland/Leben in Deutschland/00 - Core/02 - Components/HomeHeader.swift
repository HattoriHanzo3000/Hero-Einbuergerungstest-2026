import SwiftUI

// MARK: - Home Header
/// Home screen header: mascot + state title + slogan (alternating with test date and readiness when mascot animates).
struct HomeHeader: View {
    let readinessPercentage: Int
    var onPremiumTap: (() -> Void)?
    /// When false, renders content only for flat gradient headers (no rounded card).
    var useCard: Bool = true
    /// Base name for the mascot asset used in this header (e.g. "MainChick" or "MainChickFlipped").
    var mascotAssetBaseName: String = "MainChick"

    @EnvironmentObject private var stateManager: StateManager
    @EnvironmentObject private var languageManager: LanguageManager

    private var testDateMessage: String {
        TestDateMessageHelper.message(for: OnboardingPreferences.shared.testDate)
    }

    private var readinessMessage: String {
        ReadinessMessageHelper.message(readinessPercentage: readinessPercentage, languageCode: languageManager.currentAppLanguage)
    }

    var body: some View {
        let content: ScreenHeaderCardContent = stateManager.selectedState.map { stateName in
            .stateWithTestDate(stateName: stateName, testDateMessage: testDateMessage, readinessMessage: readinessMessage)
        } ?? .readiness
        return ScreenHeaderCard(
            readinessPercentage: readinessPercentage,
            onPremiumTap: onPremiumTap,
            autoPlayInterval: 60,
            content: content,
            useCard: useCard,
            mascotAssetBaseName: mascotAssetBaseName
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
