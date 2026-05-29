import SwiftUI

/// Progress section for Cockpit: wraps existing charts/cards in B2-style card chrome.
struct CockpitProgressSection: View {
    let statistics: HomeStatisticsModel
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    @State private var showExplanationSheet = false

    var body: some View {
        CockpitCard(
            titleIcon: "chart.line.uptrend.xyaxis",
            title: "cockpit_progress_title".localized,
            titleTrailing: AnyView(
                Button {
                    showExplanationSheet = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(.title3))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("progress_readiness_info_accessibility_label".localized)
                .accessibilityHint("progress_readiness_info_accessibility_hint".localized)
            )
        ) {
            HomeStatisticsSection(
                statistics: statistics,
                showTitleRow: false
            )
            .padding(.top, 2)
        }
        .padding(.horizontal)
        .sheet(isPresented: $showExplanationSheet) {
            LearnModeDisclaimerSheet(
                titleKey: "home_statistics_title",
                messageKey: "progress_readiness_explanation",
                messageFormatted: String(
                    format: "progress_readiness_explanation_full".localized,
                    statistics.totalQuestions,
                    "home_learn_spaced_repetition".localized,
                    "test_simulation_title".localized
                ),
                accentColor: Color.accentColor,
                doNotShowAgain: .constant(false),
                showDoNotShowAgain: false,
                onDismiss: { showExplanationSheet = false }
            )
            .environmentObject(languageManager)
            .environment(\.layoutMetrics, layoutMetrics)
        }
    }
}
