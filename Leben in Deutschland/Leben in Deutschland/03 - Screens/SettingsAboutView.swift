import SwiftUI

/// About screen with mascot, description, and version info. Matches Hero B2 style.
struct SettingsAboutView: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: layoutMetrics.adaptive(SettingsDesignTokens.Layout.sectionSpacing)) {
                mascotImage
                descriptionCard
                versionText
            }
            .padding(.horizontal, layoutMetrics.adaptive(20))
            .padding(.top, layoutMetrics.adaptive(8))
            .padding(.bottom, layoutMetrics.adaptive(40))
            .id(languageManager.currentAppLanguage)
        }
        .navigationTitle("settings_about_button".localized)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var mascotImage: some View {
        Group {
            if UIImage(named: "MainChick") != nil {
                Image("MainChick")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: layoutMetrics.adaptive(80)))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: layoutMetrics.adaptive(200), maxHeight: layoutMetrics.adaptive(200))
        .frame(maxWidth: .infinity)
        .padding(.vertical, layoutMetrics.adaptive(8))
        .accessibilityLabel("settings_about_mascot_accessibility".localized)
    }

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: layoutMetrics.adaptive(SettingsDesignTokens.Layout.rowSpacing)) {
            Text("settings_about_heading".localized)
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)

            Text("settings_about_description".localized)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(layoutMetrics.adaptive(16))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: layoutMetrics.adaptive(SettingsDesignTokens.Layout.cornerRadius), style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .accessibilityElement(children: .combine)
    }

    private var versionText: some View {
        Text("\("version".localized) \(appVersion)")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(layoutMetrics.adaptive(16))
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
