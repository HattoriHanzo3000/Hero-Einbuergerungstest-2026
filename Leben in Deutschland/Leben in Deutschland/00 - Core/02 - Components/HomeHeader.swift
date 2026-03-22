import SwiftUI

// MARK: - Home Header
/// Home screen header: mascot + state title + slogan. When alternatingEnabled, Progress shows alternating readiness + test date.
struct HomeHeader: View {
    let readinessPercentage: Int
    /// When true, shows premium badge in header. Progress/readiness are always visible.
    var isPremium: Bool = true
    /// When false, renders content only for flat gradient headers (no rounded card).
    var useCard: Bool = true
    /// Base name for the mascot asset used in this header (e.g. "MainChick" or "MainChickFlipped").
    var mascotAssetBaseName: String = "MainChick"
    /// When false (Home), shows only state + slogan. When true (Progress), shows alternating readiness + test date.
    var alternatingEnabled: Bool = true

    @EnvironmentObject private var stateManager: StateManager
    @EnvironmentObject private var languageManager: LanguageManager
    @ObservedObject private var onboardingPreferences = OnboardingPreferences.shared

    private var testDateMessage: String {
        TestDateMessageHelper.message(for: onboardingPreferences.testDate)
    }

    private var readinessMessage: String {
        ReadinessMessageHelper.message(readinessPercentage: readinessPercentage, languageCode: languageManager.currentAppLanguage)
    }

    var body: some View {
        let content: ScreenHeaderCardContent = stateManager.selectedState.map { stateName in
            if alternatingEnabled {
                .readinessWithTestDate(readinessMessage: readinessMessage, testDateMessage: testDateMessage)
            } else {
                .state(stateName: stateName)
            }
        } ?? .readinessWithTestDate(readinessMessage: readinessMessage, testDateMessage: testDateMessage)
        return ScreenHeaderCard(
            readinessPercentage: readinessPercentage,
            isPremium: isPremium,
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
        isPremium: true
    )
    .environmentObject(LanguageManager())
    .environmentObject(StateManager.shared)
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
