import SwiftUI

struct SettingsSupportSectionView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @ObservedObject var viewModel: SettingsSupportViewModel

    var body: some View {
        Section {
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
        .sheet(isPresented: $viewModel.isPresentingFAQ, onDismiss: {
            viewModel.dismissFAQ()
        }) {
            if let url = viewModel.faqURL {
                SettingsFAQSheetView(url: url)
            } else {
                Text("FAQ is currently unavailable.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .sheet(item: $viewModel.presentedContactMail, onDismiss: {
            viewModel.dismissContactMail()
        }) { mail in
            MailComposer(
                toRecipients: mail.recipients,
                subject: mail.subject,
                messageBody: mail.body
            )
        }
    }

}

#Preview("Support Section") {
    SettingsSupportSectionView(viewModel: SettingsSupportViewModel())
        .environmentObject(LanguageManager())
        .environmentObject(StateManager.shared)
        .environmentObject(SoundManager.shared)
}

