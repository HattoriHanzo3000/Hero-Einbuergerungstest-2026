import SwiftUI

/// Top Settings section with About, Share, and Rate rows.
struct SettingsInfoSectionView: View {
    var onAboutTapped: () -> Void
    var onShareTapped: () -> Void
    var onRateTapped: () -> Void

    var body: some View {
        Section("settings_info_title".localized) {
            Button {
                onAboutTapped()
            } label: {
                SettingsRowButtonLabel(
                    title: "settings_about_button".localized,
                    iconSystemName: "info.circle.fill",
                    tint: .gray,
                    showsChevron: true
                )
            }
            .buttonStyle(.plain)

            Button {
                onShareTapped()
            } label: {
                SettingsRowButtonLabel(
                    title: "settings_share_button".localized,
                    iconSystemName: "square.and.arrow.up",
                    tint: .blue,
                    showsChevron: true
                )
            }
            .buttonStyle(.plain)

            Button {
                onRateTapped()
            } label: {
                SettingsRowButtonLabel(
                    title: "settings_rate_app_button".localized,
                    iconSystemName: "star.fill",
                    tint: .orange,
                    showsChevron: false
                )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview("Info Section") {
    NavigationStack {
        List {
            SettingsInfoSectionView(
                onAboutTapped: {},
                onShareTapped: {},
                onRateTapped: {}
            )
        }
        .listStyle(.insetGrouped)
    }
}
