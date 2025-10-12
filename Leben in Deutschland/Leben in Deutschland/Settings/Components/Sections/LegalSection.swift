import SwiftUI

// Legal section component
struct LegalSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Section title
            HStack {
                Text("legal_title".localized)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Impressum
                SettingsButton(
                    icon: "building.2.fill",
                    title: "settings_impressum_button".localized,
                    action: {
                        viewModel.handleAction(.openImpressum)
                    }
                )
                
                // Terms of Service
                SettingsButton(
                    icon: "doc.text.fill",
                    title: "terms_of_service".localized,
                    action: {
                        viewModel.handleAction(.openTerms)
                    }
                )
                
                // Privacy Policy
                SettingsButton(
                    icon: "hand.raised.fill",
                    title: "privacy_policy".localized,
                    action: {
                        viewModel.handleAction(.openPrivacy)
                    }
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}


