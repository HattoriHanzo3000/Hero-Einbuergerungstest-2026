import SwiftUI

struct SettingsVersionSectionView: View {
    @ObservedObject var viewModel: SettingsVersionViewModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        Section {
            NavigationLink(value: SettingsDashboardRoute.version) {
                versionSummaryRow
            }
            .buttonStyle(.plain)

            Button {
                guard let url = viewModel.appStoreDestination() else { return }
                HapticManager.shared.lightImpact()
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
        HStack(spacing: SettingsDesignTokens.Layout.rowSpacing) {
            SettingsIconView(
                systemName: "info.circle.fill",
                tint: SettingsDesignTokens.Palette.updates
            )
            Text("version".localized)
                .font(.body)
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(.vertical, SettingsDesignTokens.Layout.rowVerticalPadding)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            Text(
                String(
                    format: "%@: %@",
                    "version".localized,
                    viewModel.versionInfo.currentVersion
                )
            )
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

