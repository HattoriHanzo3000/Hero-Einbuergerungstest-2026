import Combine
import Foundation
import MessageUI

@MainActor
final class SettingsSupportViewModel: ObservableObject {
    @Published var presentedContactMail: SettingsSupportMailModel?
    @Published var isPresentingFAQ: Bool = false

    let faqURL: URL?
    private let contactEmail: String

    init(
        faqURL: URL? = URL(string: "https://www.gizatech.de/hero/faq"),
        contactEmail: String = "info@gizatech.de"
    ) {
        self.faqURL = faqURL
        self.contactEmail = contactEmail
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

    func dismissContactMail() {
        presentedContactMail = nil
    }

    private func presentMail(recipients: [String], subject: String, body: String) {
        guard MFMailComposeViewController.canSendMail() else { return }

        let mail = SettingsSupportMailModel(
            recipients: recipients,
            subject: subject,
            body: body
        )
        presentedContactMail = mail
    }
}

