import SwiftUI

// Support section component
struct SupportSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        SectionContainer(title: "settings_support_title") {
            // MARK: - Buttons
            VStack(spacing: 12) {
                // MARK: - FAQ
                SettingsButton(
                    icon: "questionmark.circle.fill",
                    title: "settings_faq_button".localized,
                    action: {
                        viewModel.handleAction(.openFAQ)
                    }
                )
                
                // MARK: - Contact Support
                SettingsButton(
                    icon: "envelope.fill",
                    title: "settings_contact_button".localized,
                    action: {
                        viewModel.handleAction(.contactSupport)
                    }
                )
                
                // MARK: - Report a Bug
                SettingsButton(
                    icon: "exclamationmark.triangle.fill",
                    title: "settings_report_bug_button".localized,
                    action: {
                        viewModel.handleAction(.reportBug)
                    }
                )
            }
        }
    }
}


