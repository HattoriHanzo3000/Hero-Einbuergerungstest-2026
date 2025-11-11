import SwiftUI

struct SettingsPremiumSectionView: View {
    @ObservedObject var viewModel: SettingsPremiumViewModel

    var body: some View {
        Section {
            NavigationLink(value: SettingsDashboardRoute.premium) {
                SettingsRowButtonLabel(
                    title: "settings_premium_title".localized,
                    iconSystemName: "crown.fill",
                    tint: SettingsDesignTokens.Palette.premium,
                    showsChevron: false
                )
            }
            .buttonStyle(.plain)
            .simultaneousGesture(TapGesture().onEnded {
                viewModel.handleTap()
            })
            .accessibilityLabel(Text("settings_premium_title".localized))
            .accessibilityHint(Text("settings_premium_accessibility_hint".localized))
        }
    }
}

#Preview("Premium Section") {
    NavigationStack {
        List {
            SettingsPremiumSectionView(viewModel: SettingsPremiumViewModel())
        }
        .listStyle(.insetGrouped)
    }
}

