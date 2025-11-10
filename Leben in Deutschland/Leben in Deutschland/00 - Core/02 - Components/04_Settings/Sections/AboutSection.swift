import SwiftUI

// About section component
struct AboutSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        SettingsListSection(titleKey: "about_title") {
            SettingsListRow(
                    icon: "info.circle.fill",
                    title: "version".localized,
                    trailingText: viewModel.getAppVersion(),
                    trailingColor: .secondary,
                tintColor: .accentColor,
                showsChevron: true,
                    action: {
                        viewModel.handleAction(.showVersion)
                    }
                )
            .listRowInsets(.init(top: 0, leading: 0, bottom: MainScreenConstants.adaptiveValue(6), trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
                
            SettingsListRow(
                    icon: "arrow.down.circle.fill",
                    title: "settings_check_updates_button".localized,
                tintColor: .blue,
                showsChevron: true,
                    action: {
                        viewModel.handleAction(.checkUpdates)
                    }
                )
            .listRowInsets(.init(top: 0, leading: 0, bottom: MainScreenConstants.adaptiveValue(6), trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
                
            SettingsListRow(
                    icon: "app.badge.fill",
                    title: "settings_open_app_store_button".localized,
                tintColor: .indigo,
                showsChevron: true,
                    action: {
                        viewModel.handleAction(.openAppStore)
                    }
                )
            .listRowInsets(.init(top: 0, leading: 0, bottom: MainScreenConstants.adaptiveValue(6), trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
                
            SettingsListRow(
                    icon: "flask.fill",
                    title: "Test Alerts",
                tintColor: .orange,
                    foregroundColor: .orange,
                showsChevron: true,
                    action: {
                        viewModel.handleAction(.testAlerts)
                    }
                )
            .listRowInsets(.init(top: 0, leading: 0, bottom: MainScreenConstants.adaptiveValue(6), trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }
}


