import SwiftUI

/// Top Settings section with About and Share rows. Uses app-blue icon tint.
struct SettingsInfoSectionView: View {
    var onAboutTapped: () -> Void
    var onShareTapped: () -> Void

    private static let appBlue = Color.accentColor

    var body: some View {
        Section {
            Button {
                onAboutTapped()
            } label: {
                SettingsRowButtonLabel(
                    title: "settings_about_button".localized,
                    iconSystemName: "info.circle.fill",
                    tint: Self.appBlue,
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
                    tint: Self.appBlue,
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
