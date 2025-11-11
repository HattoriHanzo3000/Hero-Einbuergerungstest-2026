import SwiftUI

struct SettingsDangerSectionView: View {
    @ObservedObject var viewModel: SettingsDangerViewModel

    var body: some View {
        Section {
            Button(role: .destructive) {
                viewModel.requestConfirmation()
            } label: {
                HStack(spacing: SettingsDesignTokens.Layout.rowSpacing) {
                    SettingsIconView(systemName: "arrow.counterclockwise.circle.fill", tint: SettingsDesignTokens.Palette.danger)
                    Text("settings_reset_app".localized)
                        .font(.body)
                    Spacer()
                }
                .padding(.vertical, SettingsDesignTokens.Layout.rowVerticalPadding)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .alert(
            "delete_statistics_warning_title".localized,
            isPresented: $viewModel.isPresentingConfirmation,
            actions: {
                Button("cancel".localized, role: .cancel) {
                    viewModel.cancel()
                }
                Button("delete_button".localized, role: .destructive) {
                    viewModel.confirm()
                }
            },
            message: {
                Text("delete_statistics_warning_message".localized)
            }
        )
    }
}

#Preview("Danger Section") {
    let languageManager = LanguageManager()
    let stateManager = StateManager()
    let soundManager = SoundManager.shared
    let viewModel = SettingsDangerViewModel(
        soundManager: soundManager,
        languageManager: languageManager,
        stateManager: stateManager
    )
    return SettingsDangerSectionView(
        viewModel: viewModel
    )
    .environmentObject(languageManager)
    .environmentObject(stateManager)
    .environmentObject(soundManager)
    .environmentObject(AppFlow())
}

