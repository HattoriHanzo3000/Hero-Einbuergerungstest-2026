import SwiftUI

// Legal section component
struct LegalSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        SettingsListSection(titleKey: "legal_title") {
            SettingsListRow(
                    icon: "building.2.fill",
                    title: "settings_impressum_button".localized,
                tintColor: .mint,
                showsChevron: true,
                    action: {
                        viewModel.handleAction(.openImpressum)
                    }
                )
            .listRowInsets(.init(top: 0, leading: 0, bottom: MainScreenConstants.adaptiveValue(6), trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
                
            SettingsListRow(
                    icon: "doc.text.fill",
                    title: "terms_of_service".localized,
                tintColor: .indigo,
                showsChevron: true,
                    action: {
                        viewModel.handleAction(.openTerms)
                    }
                )
            .listRowInsets(.init(top: 0, leading: 0, bottom: MainScreenConstants.adaptiveValue(6), trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
                
            SettingsListRow(
                    icon: "hand.raised.fill",
                    title: "privacy_policy".localized,
                tintColor: .green,
                showsChevron: true,
                    action: {
                        viewModel.handleAction(.openPrivacy)
                    }
                )
            .listRowInsets(.init(top: 0, leading: 0, bottom: MainScreenConstants.adaptiveValue(6), trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }
}


