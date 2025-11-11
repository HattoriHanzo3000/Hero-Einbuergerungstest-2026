import SwiftUI

struct SettingsLegalSectionView: View {
    @ObservedObject var viewModel: SettingsLegalViewModel
    var body: some View {
        Section {
            Button {
                HapticManager.shared.lightImpact()
                viewModel.presentImpressum()
            } label: {
                SettingsRowButtonLabel(
                    title: "settings_impressum_button".localized,
                    iconSystemName: "building.2.fill",
                    tint: SettingsDesignTokens.Palette.legal,
                    showsChevron: false
                )
            }
            .buttonStyle(.plain)

            Button {
                HapticManager.shared.lightImpact()
                viewModel.presentTerms()
            } label: {
                SettingsRowButtonLabel(
                    title: "terms_of_service".localized,
                    iconSystemName: "doc.text.fill",
                    tint: SettingsDesignTokens.Palette.legal,
                    showsChevron: false
                )
            }
            .buttonStyle(.plain)

            Button {
                HapticManager.shared.lightImpact()
                viewModel.presentPrivacy()
            } label: {
                SettingsRowButtonLabel(
                    title: "privacy_policy".localized,
                    iconSystemName: "lock.fill",
                    tint: SettingsDesignTokens.Palette.legal,
                    showsChevron: false
                )
            }
            .buttonStyle(.plain)
        }
        .sheet(item: $viewModel.presentingWebURL, onDismiss: {
            viewModel.dismissWeb()
        }) { document in
            SettingsLegalWebSheetView(url: document.url)
        }
    }
}

#Preview("Legal Section") {
    SettingsLegalSectionView(viewModel: SettingsLegalViewModel())
        .environmentObject(LanguageManager())
        .environmentObject(StateManager())
        .environmentObject(SoundManager.shared)
}

