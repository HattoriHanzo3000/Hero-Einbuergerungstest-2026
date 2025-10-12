import SwiftUI

// About section component
struct AboutSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Section title
            HStack {
                Text("about_title".localized)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                // App Version
                SettingsButton(
                    icon: "info.circle.fill",
                    title: "version".localized,
                    trailingText: viewModel.getAppVersion(),
                    trailingColor: .secondary,
                    action: {
                        viewModel.handleAction(.showVersion)
                    }
                )
                
                // Check for Updates
                SettingsButton(
                    icon: "arrow.down.circle.fill",
                    title: "settings_check_updates_button".localized,
                    action: {
                        viewModel.handleAction(.checkUpdates)
                    }
                )
                
                // Open App Store
                SettingsButton(
                    icon: "app.badge.fill",
                    title: "settings_open_app_store_button".localized,
                    action: {
                        viewModel.handleAction(.openAppStore)
                    }
                )
                
                // Test Alerts Button (Development)
                SettingsButton(
                    icon: "flask.fill",
                    title: "Test Alerts",
                    backgroundColor: Color.orange.opacity(0.2),
                    foregroundColor: .orange,
                    action: {
                        viewModel.handleAction(.testAlerts)
                    }
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}


