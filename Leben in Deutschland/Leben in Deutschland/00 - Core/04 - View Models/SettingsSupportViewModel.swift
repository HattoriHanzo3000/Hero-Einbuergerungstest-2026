import Combine
import Foundation
import MessageUI
import UIKit

@MainActor
final class SettingsSupportViewModel: ObservableObject {
    @Published var presentedContactMail: SettingsSupportMailModel?
    @Published var isPresentingFAQ: Bool = false
    @Published var showMailUnavailableAlert: Bool = false

    let faqURL: URL?
    private let contactEmail: String

    init(
        faqURL: URL? = AppURLs.faq,
        contactEmail: String = AppURLs.contactEmail
    ) {
        self.faqURL = faqURL
        self.contactEmail = contactEmail
    }

    func presentFAQ() {
        HapticManager.shared.lightImpact()
        isPresentingFAQ = true
    }

    func dismissFAQ() {
        isPresentingFAQ = false
    }

    func contactSupport() {
        HapticManager.shared.lightImpact()
        if MFMailComposeViewController.canSendMail() {
            presentMail(
                recipients: [contactEmail],
                subject: "Contact - Leben in Deutschland",
                body: Self.deviceInfoBody
            )
        } else {
            openMailtoFallback()
        }
    }

    func dismissContactMail() {
        presentedContactMail = nil
    }

    func dismissMailUnavailableAlert() {
        showMailUnavailableAlert = false
    }

    private func presentMail(recipients: [String], subject: String, body: String) {
        let mail = SettingsSupportMailModel(
            recipients: recipients,
            subject: subject,
            body: body
        )
        presentedContactMail = mail
    }

    private func openMailtoFallback() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let deviceModel = UIDevice.current.model
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion

        let body = String(format: "mail_device_info_body".localized, appVersion, buildNumber, deviceModel, systemName, systemVersion)
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? body
        let subject = "Contact - Leben in Deutschland".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Contact"

        let mailtoString = "mailto:\(contactEmail)?subject=\(subject)&body=\(encodedBody)"
        guard let mailtoURL = URL(string: mailtoString) else {
            showMailUnavailableAlert = true
            return
        }

        UIApplication.shared.open(mailtoURL) { [weak self] success in
            Task { @MainActor in
                if !success {
                    self?.showMailUnavailableAlert = true
                }
            }
        }
    }

    /// Pre-filled mail body with device info to help support respond effectively.
    private static var deviceInfoBody: String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let deviceModel = UIDevice.current.model
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion

        return String(format: "mail_device_info_body".localized, appVersion, buildNumber, deviceModel, systemName, systemVersion)
    }
}
