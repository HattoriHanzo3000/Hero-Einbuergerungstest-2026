import SwiftUI

// Statistics section component
struct StatisticsSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Section title
            HStack {
                Text("settings_statistics_title".localized)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Delete Statistics Button
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
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
