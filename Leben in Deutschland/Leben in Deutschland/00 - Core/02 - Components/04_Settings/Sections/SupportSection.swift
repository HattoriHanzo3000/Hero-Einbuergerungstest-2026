import SwiftUI

// Support section component
struct SupportSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        SettingsListSection(titleKey: "settings_support_title") {
            SettingsListRow(
                    icon: "questionmark.circle.fill",
                    title: "settings_faq_button".localized,
                tintColor: .teal,
                showsChevron: true,
                    action: {
                        viewModel.handleAction(.openFAQ)
                    }
                )
            .listRowInsets(.init(top: 0, leading: 0, bottom: MainScreenConstants.adaptiveValue(6), trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
                
            SettingsListRow(
                    icon: "envelope.fill",
                    title: "settings_contact_button".localized,
                tintColor: .blue,
                showsChevron: true,
                    action: {
                        viewModel.handleAction(.contactSupport)
                    }
                )
            .listRowInsets(.init(top: 0, leading: 0, bottom: MainScreenConstants.adaptiveValue(6), trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
                
            SettingsListRow(
                    icon: "exclamationmark.triangle.fill",
                    title: "settings_report_bug_button".localized,
                tintColor: .orange,
                foregroundColor: .orange,
                showsChevron: true,
                    action: {
                        viewModel.handleAction(.reportBug)
                    }
                )
            .listRowInsets(.init(top: 0, leading: 0, bottom: MainScreenConstants.adaptiveValue(6), trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }
}


