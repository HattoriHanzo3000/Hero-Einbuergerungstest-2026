import SwiftUI
import UIKit

struct SettingsVersionDetailView: View {
    @ObservedObject var viewModel: SettingsVersionViewModel

    var body: some View {
        List {
            Section("settings_current_version".localized) {
                versionCard(
                    title: "\("version".localized) \(viewModel.versionInfo.currentVersion)",
                    description: "settings_version_updates".localized
                )
            }

            if viewModel.latestVersionIsNewer {
                Section("settings_update_available".localized) {
                    versionCard(
                        title: "\("version".localized) \(viewModel.versionInfo.latestAvailableVersion)",
                        description: "settings_version_updates_placeholder".localized
                    )

                    Button {
                        HapticManager.shared.mediumImpact()
                        if let url = viewModel.appStoreDestination() {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("settings_update_now".localized)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.top, 8)
                    .accessibilityHint(Text("settings_update_button_hint".localized))
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("version".localized)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func versionCard(title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: SettingsDesignTokens.Layout.rowSpacing) {
            appIcon
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 4)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(description))
    }

    private var appIcon: Image {
        if let iconName = UIApplication.shared.alternateIconName,
           let image = UIImage(named: iconName) {
            return Image(uiImage: image)
        }

        if let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last,
           let image = UIImage(named: lastIcon) {
            return Image(uiImage: image)
        }

        return Image(systemName: "app.fill")
    }
}

#Preview("Version Detail") {
    NavigationStack {
        SettingsVersionDetailView(viewModel: SettingsVersionViewModel())
    }
}

