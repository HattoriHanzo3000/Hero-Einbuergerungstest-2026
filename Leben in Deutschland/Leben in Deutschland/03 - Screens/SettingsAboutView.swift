import SwiftUI

/// About screen with mascot, description, and version info. Matches Hero B2 style.
struct SettingsAboutView: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(LiquidGlassGradient.blue.screenBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: layoutMetrics.adaptive(SettingsDesignTokens.Layout.sectionSpacing)) {
                    mascotImage
                    descriptionText
                    versionText
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

    private var versionText: some View {
        Text("\("version".localized) \(appVersion)")
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.85))
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel("version".localized)
            .accessibilityValue(appVersion)
    }
}

#Preview("About") {
    NavigationStack {
        SettingsAboutView()
            .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
    }
}
