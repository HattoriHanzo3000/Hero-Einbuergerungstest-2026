import SwiftUI

// Support section component
struct SupportSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Section title
            HStack {
                Text("settings_support_title".localized)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                // FAQ
                SettingsButton(
                    icon: "questionmark.circle.fill",
                    title: "settings_faq_button".localized,
                    action: {
                        viewModel.handleAction(.openFAQ)
                    }
                )
                
                // Contact
                SettingsButton(
                    icon: "envelope.fill",
                    title: "settings_contact_button".localized,
                    action: {
                        viewModel.handleAction(.contactSupport)
                    }
                )
                
                // Report a Bug
                SettingsButton(
                    icon: "exclamationmark.triangle.fill",
                    title: "settings_report_bug_button".localized,
                    action: {
                        viewModel.handleAction(.reportBug)
                    }
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}


