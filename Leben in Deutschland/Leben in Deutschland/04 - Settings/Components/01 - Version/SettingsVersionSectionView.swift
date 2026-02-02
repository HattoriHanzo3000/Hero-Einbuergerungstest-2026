import SwiftUI

struct SettingsVersionSectionView: View {
    @ObservedObject var viewModel: SettingsVersionViewModel
    @Environment(\.openURL) private var openURL
    var onOpenVersion: () -> Void

    init(viewModel: SettingsVersionViewModel, onOpenVersion: @escaping () -> Void = {}) {
        self.viewModel = viewModel
        self.onOpenVersion = onOpenVersion
    }

    var body: some View {
        Section {
            Button {
                onOpenVersion()
            } label: {
                versionSummaryRow
            }
            .buttonStyle(.plain)

            Button {
                guard let url = viewModel.appStoreDestination() else { return }
                openURL(url)
            } label: {
                SettingsRowButtonLabel(
                    title: "settings_open_app_store_button".localized,
                    iconSystemName: "app.badge.fill",
                    tint: SettingsDesignTokens.Palette.updates,
                    showsChevron: false
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var versionSummaryRow: some View {
        SettingsRowButtonLabel(
            title: "version".localized,
            iconSystemName: "info.circle.fill",
            tint: SettingsDesignTokens.Palette.updates,
            showsBadge: viewModel.latestVersionIsNewer,
            showsChevron: true
        )
    }

}

#Preview("Version Section") {
    NavigationStack {
        List {
            SettingsVersionSectionView(viewModel: SettingsVersionViewModel())
        }
        .listStyle(.insetGrouped)
    }
}

