import SwiftUI

/// About screen with mascot and description. Matches Hero B2 style.
struct SettingsAboutView: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        ZStack {
            Rectangle()
                .fill(LiquidGlassGradient.blue.screenBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: layoutMetrics.adaptive(SettingsDesignTokens.Layout.sectionSpacing)) {
                    mascotImage
                    descriptionText
                        .padding(.bottom, layoutMetrics.adaptive(20))
                    learningOptionsTitle
                    disclaimerSection
                    legalDisclaimerSection
                        .padding(.top, layoutMetrics.adaptive(8))
                }
                .padding(.horizontal, layoutMetrics.adaptive(20))
                .padding(.top, layoutMetrics.adaptive(8))
                .padding(.bottom, layoutMetrics.adaptive(40))
                .id(languageManager.currentAppLanguage)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("settings_about_button".localized)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var mascotImage: some View {
        Group {
            if UIImage(named: "MainChick_About") != nil {
                Image("MainChick_About")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: layoutMetrics.adaptive(80)))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: layoutMetrics.adaptive(200), maxHeight: layoutMetrics.adaptive(200))
        .frame(maxWidth: .infinity)
        .padding(.vertical, layoutMetrics.adaptive(8))
        .accessibilityLabel("settings_about_mascot_accessibility".localized)
    }

    private var descriptionText: some View {
        Text("settings_about_description".localized)
            .font(.body)
            .foregroundStyle(.white.opacity(0.95))
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var learningOptionsTitle: some View {
        Text("settings_about_learning_options_title".localized)
            .font(.title2)
            .foregroundStyle(.white.opacity(0.95))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Learning options in home order. Titles match Home buttons (and gate sheet) except Test, which keeps disclaimer title.
    private var disclaimerSection: some View {
        VStack(alignment: .leading, spacing: layoutMetrics.adaptive(SettingsDesignTokens.Layout.sectionSpacing)) {
            disclaimerBlock(titleKey: "home_learn_all_questions", messageKey: "all_questions_disclaimer_message")
            disclaimerBlock(titleKey: "home_learn_by_topics", messageKey: "learn_by_topics_disclaimer_message")
            disclaimerBlock(titleKey: "home_learn_spaced_repetition", messageKey: "sr_disclaimer_message")
            disclaimerBlock(titleKey: "test_simulation_disclaimer_title", messageKey: "test_simulation_disclaimer_message")
        }
    }

    private func disclaimerBlock(titleKey: String, messageKey: String) -> some View {
        VStack(alignment: .leading, spacing: layoutMetrics.adaptive(8)) {
            Text(titleKey.localized)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.95))
            Text(messageKey.localized)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var legalDisclaimerSection: some View {
        VStack(alignment: .leading, spacing: layoutMetrics.adaptive(10)) {
            Divider()
                .overlay(.white.opacity(0.25))

            Text("disclaimer_title".localized)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.95))

            Text("about_disclaimer".localized)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("About") {
    NavigationStack {
        SettingsAboutView()
            .environmentObject(LanguageManager())
            .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
    }
}
