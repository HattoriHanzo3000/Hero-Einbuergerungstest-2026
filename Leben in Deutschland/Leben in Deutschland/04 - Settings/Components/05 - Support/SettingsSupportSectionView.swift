import SwiftUI
import UIKit

struct SettingsSupportSectionView: View {
    @ObservedObject var viewModel: SettingsSupportViewModel
    @Environment(\.openURL) private var openURL

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

            Button {
                viewModel.reportBug(deviceInfoProvider: Self.deviceInfo)
            } label: {
                SettingsRowButtonLabel(
                    title: "settings_report_bug_button".localized,
                    iconSystemName: "flag.fill",
                    tint: SettingsDesignTokens.Palette.support,
                    showsChevron: false
                )
            }
            .buttonStyle(.plain)
        }
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
        .sheet(item: $viewModel.presentedBugMail, onDismiss: {
            viewModel.dismissBugMail()
        }) { mail in
            MailComposer(
                toRecipients: mail.recipients,
                subject: mail.subject,
                messageBody: mail.body
            )
        }
    }

    @MainActor private static func deviceInfo() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let deviceModel = UIDevice.current.model
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion

        return """

        ---
        App Version: \(appVersion) (\(buildNumber))
        Device: \(deviceModel)
        iOS Version: \(systemName) \(systemVersion)

        Please describe your issue below this line.
        ---

        """
    }
}

#Preview("Support Section") {
    SettingsSupportSectionView(viewModel: SettingsSupportViewModel())
        .environmentObject(LanguageManager())
        .environmentObject(StateManager.shared)
        .environmentObject(SoundManager.shared)
}

