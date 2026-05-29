import SwiftUI

// MARK: - Home Header
/// Shared top header for Home and Progress.
/// Uses alternating copy mode to rotate slogan, test date, and readiness.
struct HomeHeader: View {
    let readinessPercentage: Int
    /// When true, user is Pro; header hides free upsell chip.
    var isProUser: Bool = true
    /// When false, renders content only for flat gradient headers (no rounded card).
    var useCard: Bool = true
    /// B2-style horizontal mirror for the header mascot (Main + Progress).
    var mascotHorizontallyFlipped: Bool = false
    /// When true, rotates through slogan + test date + readiness.
    /// Both Home and Progress should keep this enabled for unified behavior.
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
                .stateWithTestDate(
                    stateName: stateName,
                    testDateMessage: testDateMessage,
                    readinessMessage: readinessMessage
                )
            } else {
                .state(stateName: stateName)
            }
        } ?? .readinessWithTestDate(readinessMessage: readinessMessage, testDateMessage: testDateMessage)

        return ScreenHeaderCard(
            readinessPercentage: readinessPercentage,
            isProUser: isProUser,
            autoPlayInterval: 60,
            content: content,
            useCard: useCard,
            mascotHorizontallyFlipped: mascotHorizontallyFlipped
        )
        // Keep header typography fixed (no Dynamic Type scaling).
        .dynamicTypeSize(.large ... .large)
    }
}

// MARK: - Preview
#Preview {
    HomeHeader(
        readinessPercentage: 72,
        isProUser: true
    )
    .environmentObject(LanguageManager())
    .environmentObject(StateManager.shared)
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
