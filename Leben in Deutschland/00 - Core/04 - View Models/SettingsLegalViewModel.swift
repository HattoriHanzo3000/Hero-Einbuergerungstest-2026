import Combine
import Foundation

@MainActor
final class SettingsLegalViewModel: ObservableObject {
    @Published var presentingWebURL: LegalDocument?

    let impressumURL: URL
    let termsURL: URL
    let privacyURL: URL

    init(
        impressumURL: URL = AppURLs.impressum,
        termsURL: URL = AppURLs.termsOfUse,
        privacyURL: URL = AppURLs.privacyPolicy
    ) {
        self.impressumURL = impressumURL
        self.termsURL = termsURL
        self.privacyURL = privacyURL
    }

    func presentWeb(url: URL) {
        HapticManager.shared.lightImpact()
        presentingWebURL = LegalDocument(url: url)
    }

    func presentImpressum() {
        presentWeb(url: impressumURL)
    }

    func presentTerms() {
        presentWeb(url: termsURL)
    }

    func presentPrivacy() {
        presentWeb(url: privacyURL)
    }

    func dismissWeb() {
        presentingWebURL = nil
    }

    struct LegalDocument: Identifiable {
        let url: URL
        var id: URL { url }
    }
}
