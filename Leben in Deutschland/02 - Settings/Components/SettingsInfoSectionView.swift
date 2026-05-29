import SwiftUI

/// Top Settings section with About and Share rows.
struct SettingsInfoSectionView: View {
    var onAboutTapped: () -> Void
    var onShareTapped: () -> Void

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
        }
    }
}

#Preview("Info Section") {
    NavigationStack {
        List {
            SettingsInfoSectionView(
                onAboutTapped: {},
                onShareTapped: {}
            )
        }
        .listStyle(.insetGrouped)
    }
}
