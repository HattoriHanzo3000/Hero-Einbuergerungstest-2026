import SwiftUI

// MARK: - Home Header
/// Home screen header: mascot + state title + slogan (alternating with test date and readiness when mascot animates).
struct HomeHeader: View {
    let readinessPercentage: Int
    /// When false, readiness score is hidden (premium-only feature).
    var isPremium: Bool = true
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
            .stateWithTestDate(
                stateName: stateName,
                testDateMessage: testDateMessage,
                readinessMessage: isPremium ? readinessMessage : nil
            )
        } ?? (isPremium ? .readiness : .message("progress_premium_gate_message".localized))
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
