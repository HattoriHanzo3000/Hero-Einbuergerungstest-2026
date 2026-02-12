import SwiftUI

struct SettingsSupportSectionView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @ObservedObject var viewModel: SettingsSupportViewModel

    var body: some View {
        Section("settings_support_title".localized) {
            Button {
                viewModel.presentFAQ()
            } label: {
                SettingsRowButtonLabel(
                    title: "settings_faq_button".localized,
                    iconSystemName: "questionmark.circle.fill",
                    tint: SettingsDesignTokens.Palette.support,
                    showsChevron: false
                )
            }
            .buttonStyle(.plain)

            Button {
                viewModel.contactSupport()
            } label: {
                SettingsRowButtonLabel(
                    title: "settings_contact_button".localized,
                    iconSystemName: "envelope.fill",
                    tint: SettingsDesignTokens.Palette.support,
                    showsChevron: false
                )
            }
            .buttonStyle(.plain)
        }
        .id(languageManager.currentAppLanguage)
    }

}

#Preview("Support Section") {
    SettingsSupportSectionView(viewModel: SettingsSupportViewModel())
        .environmentObject(LanguageManager())
        .environmentObject(StateManager.shared)
        .environmentObject(SoundManager.shared)
}

