import SwiftUI

struct SettingsVersionSectionView: View {
    @ObservedObject var viewModel: SettingsVersionViewModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        Section {
            versionInfoRow
            Button {
                HapticManager.shared.lightImpact()
                viewModel.checkForUpdates()
            } label: {
                SettingsRowButtonLabel(
                    title: "settings_check_updates_button".localized,
                    iconSystemName: "arrow.down.circle.fill",
                    tint: SettingsDesignTokens.Color.updates,
                    showsChevron: false
                )
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
                    tint: SettingsDesignTokens.Color.updates,
                    showsChevron: false
                )
            }
            .buttonStyle(.plain)
        }
        .alert(
            viewModel.alert?.title ?? "",
            isPresented: Binding(
                get: { viewModel.alert != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.dismissAlert()
                    }
                }
            ),
            presenting: viewModel.alert
        ) { alert in
            switch alert.kind {
            case .latest:
                Button("ok".localized, role: .cancel) {
                    viewModel.dismissAlert()
                }
            case .available:
                Button("update_now".localized) {
                    guard let url = viewModel.appStoreDestination() else { return }
                    openURL(url)
                    viewModel.dismissAlert()
                }
                Button("update_later".localized, role: .cancel) {
                    viewModel.dismissAlert()
                }
            }
        } message: { alert in
            Text(alert.message())
        }
    }

    private var versionInfoRow: some View {
        HStack(spacing: SettingsDesignTokens.Layout.rowSpacing) {
            SettingsIconView(
                systemName: "info.circle.fill",
                tint: SettingsDesignTokens.Color.updates
            )
            VStack(alignment: .leading, spacing: 4) {
                Text("version".localized)
                    .font(.body.weight(.semibold))
                Text(
                    String(
                        format: "%@: %@",
                        "settings_installed_version".localized,
                        viewModel.versionInfo.currentVersion
                    )
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 6)
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

