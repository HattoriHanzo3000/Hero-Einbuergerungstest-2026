import SwiftUI

// Statistics section component
struct StatisticsSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        SettingsListSection(titleKey: "settings_statistics_title") {
            SettingsListRow(
                icon: "trash.fill",
                title: "settings_delete_statistics".localized,
                tintColor: .red,
                foregroundColor: .red,
                showsChevron: true,
                action: {
                    viewModel.handleAction(.deleteStatistics)
                }
            )
            .listRowInsets(.init(top: 0, leading: 0, bottom: MainScreenConstants.adaptiveValue(6), trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }
}
