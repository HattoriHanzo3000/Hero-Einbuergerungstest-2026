import Combine
import Foundation
import MessageUI

@MainActor
final class SettingsSupportViewModel: ObservableObject {
    @Published var presentedContactMail: SettingsSupportMailModel?
    @Published var presentedBugMail: SettingsSupportMailModel?
    @Published var isPresentingFAQ: Bool = false

    let faqURL: URL?
    private let contactEmail: String
    private let bugReportEmail: String

    init(
        faqURL: URL? = URL(string: "https://www.gizatech.de/hero/faq"),
        contactEmail: String = "info@gizatech.de",
        bugReportEmail: String = "support@gizatech.de"
    ) {
        self.faqURL = faqURL
        self.contactEmail = contactEmail
        self.bugReportEmail = bugReportEmail
    }

    func presentFAQ() {
        isPresentingFAQ = true
    }

    func dismissFAQ() {
        isPresentingFAQ = false
    }

    func contactSupport() {
        presentMail(
            recipients: [contactEmail],
            subject: "Contact - Leben in Deutschland",
            body: ""
        )
    }

    func reportBug(deviceInfoProvider: () -> String) {
        presentMail(
            recipients: [bugReportEmail],
            subject: "Bug Report - Leben in Deutschland",
            body: deviceInfoProvider()
        )
    }

    func dismissContactMail() {
        presentedContactMail = nil
    }

    func dismissBugMail() {
        presentedBugMail = nil
    }

    private func presentMail(recipients: [String], subject: String, body: String) {
        guard MFMailComposeViewController.canSendMail() else { return }

        let mail = SettingsSupportMailModel(
            recipients: recipients,
            subject: subject,
            body: body
        )

        if recipients == [contactEmail] {
            presentedContactMail = mail
        } else {
            presentedBugMail = mail
        }
    }
}

