import Combine
import Foundation

@MainActor
final class SettingsLegalViewModel: ObservableObject {
    @Published var presentingWebURL: LegalDocument?

    let impressumURL: URL
    let termsURL: URL
    let privacyURL: URL

    init(
        impressumURL: URL = URL(string: "https://www.gizatech.de/hero/impressum")!,
        termsURL: URL = URL(string: "https://www.gizatech.de/hero/terms-of-use")!,
        privacyURL: URL = URL(string: "https://www.gizatech.de/hero/privacy-policy")!
    ) {
        self.impressumURL = impressumURL
        self.termsURL = termsURL
        self.privacyURL = privacyURL
    }

    func presentImpressum() {
        presentingWebURL = LegalDocument(url: impressumURL)
    }

    func presentTerms() {
        presentingWebURL = LegalDocument(url: termsURL)
    }

    func presentPrivacy() {
        presentingWebURL = LegalDocument(url: privacyURL)
    }

    func dismissWeb() {
        presentingWebURL = nil
    }

    struct LegalDocument: Identifiable {
        let url: URL
        var id: URL { url }
    }
}

