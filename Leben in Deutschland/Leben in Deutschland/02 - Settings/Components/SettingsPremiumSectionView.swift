import SwiftUI

struct SettingsProSectionView: View {
    @ObservedObject var viewModel: SettingsProViewModel

    var body: some View {
        Section("settings_premium_title".localized) {
            Button {
                viewModel.handleTap()
            } label: {
                SettingsRowButtonLabel(
                    title: "settings_premium_title".localized,
                    iconSystemName: "crown.fill",
                    tint: SettingsDesignTokens.Palette.premium,
                    showsChevron: false
                )
            }
            .buttonStyle(.borderless)
            .tint(.primary)
            .accessibilityLabel(Text("settings_premium_title".localized))
            .accessibilityHint(Text("settings_premium_accessibility_hint".localized))
        }
    }
}

#Preview("Pro Section") {
    NavigationStack {
        List {
            SettingsProSectionView(viewModel: SettingsProViewModel())
        }
        .listStyle(.insetGrouped)
    }
}

typealias SettingsPremiumSectionView = SettingsProSectionView

