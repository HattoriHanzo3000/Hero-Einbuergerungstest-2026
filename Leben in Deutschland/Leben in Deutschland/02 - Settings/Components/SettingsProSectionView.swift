import SwiftUI

struct SettingsProSectionView: View {
    @ObservedObject var viewModel: SettingsProViewModel
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared

    var body: some View {
        Section("settings_pro_title".localized) {
            Button {
                viewModel.handleTap()
            } label: {
                SettingsRowButtonLabel(
                    title: "hero_pro_nav_title".localized,
                    subtitle: subscriptionManager.localizedPlanStatusLine,
                    iconSystemName: "creditcard.fill",
                    tint: Color("AppBlue"),
                    showsChevron: false
                )
            }
            .buttonStyle(.borderless)
            .tint(.primary)
            .accessibilityLabel(Text("hero_pro_nav_title".localized))
            .accessibilityValue(Text(subscriptionManager.localizedPlanStatusLine))
            .accessibilityHint(Text("settings_pro_accessibility_hint".localized))
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

