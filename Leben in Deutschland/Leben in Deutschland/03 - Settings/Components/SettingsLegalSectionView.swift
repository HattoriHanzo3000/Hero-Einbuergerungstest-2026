import SwiftUI

struct SettingsLegalSectionView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @ObservedObject var viewModel: SettingsLegalViewModel

    var body: some View {
        Section("legal_title".localized) {
            Button {
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
        .id(languageManager.currentAppLanguage)
    }
}

#Preview("Legal Section") {
    SettingsLegalSectionView(viewModel: SettingsLegalViewModel())
        .environmentObject(LanguageManager())
        .environmentObject(StateManager.shared)
        .environmentObject(SoundManager.shared)
}

