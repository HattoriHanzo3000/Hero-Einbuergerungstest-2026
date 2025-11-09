import SwiftUI

// Statistics section component
struct StatisticsSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        SectionContainer(title: "settings_statistics_title") {
            // MARK: - Delete Statistics
            SettingsButton(
                icon: "trash.fill",
                title: "settings_delete_statistics".localized,
                backgroundColor: Color.red.opacity(0.1),
                foregroundColor: Color.red,
                action: {
                    viewModel.handleAction(.deleteStatistics)
                }
            )
        }
    }
}
