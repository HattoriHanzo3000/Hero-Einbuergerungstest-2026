import SwiftUI

// Legal section component
struct LegalSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        SectionContainer(title: "legal_title") {
            // MARK: - Legal Buttons
            VStack(spacing: 12) {
                // MARK: - Impressum
                SettingsButton(
                    icon: "building.2.fill",
                    title: "settings_impressum_button".localized,
                    action: {
                        viewModel.handleAction(.openImpressum)
                    }
                )
                
                // MARK: - Terms of Service
                SettingsButton(
                    icon: "doc.text.fill",
                    title: "terms_of_service".localized,
                    action: {
                        viewModel.handleAction(.openTerms)
                    }
                )
                
                // MARK: - Privacy Policy
                SettingsButton(
                    icon: "hand.raised.fill",
                    title: "privacy_policy".localized,
                    action: {
                        viewModel.handleAction(.openPrivacy)
                    }
                )
            }
        }
    }
}


