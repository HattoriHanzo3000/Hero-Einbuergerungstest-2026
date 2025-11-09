import SwiftUI

// About section component
struct AboutSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        SectionContainer(title: "about_title") {
            // MARK: - Buttons
            VStack(spacing: 12) {
                // MARK: - App Version
                SettingsButton(
                    icon: "info.circle.fill",
                    title: "version".localized,
                    trailingText: viewModel.getAppVersion(),
                    trailingColor: .secondary,
                    action: {
                        viewModel.handleAction(.showVersion)
                    }
                )
                
                // MARK: - Check for Updates
                SettingsButton(
                    icon: "arrow.down.circle.fill",
                    title: "settings_check_updates_button".localized,
                    action: {
                        viewModel.handleAction(.checkUpdates)
                    }
                )
                
                // MARK: - Open App Store
                SettingsButton(
                    icon: "app.badge.fill",
                    title: "settings_open_app_store_button".localized,
                    action: {
                        viewModel.handleAction(.openAppStore)
                    }
                )
                
                // MARK: - Test Alerts
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
    }
}


