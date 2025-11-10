import SwiftUI

// Personalisation section component (Sound, Vibration, Appearance)
struct PersonalisationSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        SettingsListSection(titleKey: "settings_personalisation_title") {
            SettingsListRow(
                    icon: "speaker.wave.2.fill",
                    title: "settings_sound_button".localized,
                tintColor: viewModel.isSoundEnabled ? .blue : Color(.systemGray4),
                    action: {
                        viewModel.toggleSound()
                    },
                    trailingContent: {
                        Text(viewModel.isSoundEnabled ? "on".localized : "off".localized)
                            .foregroundColor(.secondary)
                    }
                )
            .listRowInsets(.init(top: 0, leading: 0, bottom: MainScreenConstants.adaptiveValue(6), trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
                
            SettingsListRow(
                    icon: "iphone.radiowaves.left.and.right",
                    title: "settings_vibration_button".localized,
                tintColor: viewModel.isVibrationEnabled ? .blue : Color(.systemGray4),
                    action: {
                        viewModel.toggleVibration()
                    },
                    trailingContent: {
                        Text(viewModel.isVibrationEnabled ? "on".localized : "off".localized)
                            .foregroundColor(.secondary)
                    }
                )
            .listRowInsets(.init(top: 0, leading: 0, bottom: MainScreenConstants.adaptiveValue(6), trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
                
            SettingsListRow(
                    icon: "paintbrush.fill",
                    title: "settings_appearance".localized,
                tintColor: .purple,
                showsChevron: true,
                    action: {
                        viewModel.cycleAppearance()
                    },
                    trailingContent: {
                        Text(viewModel.appearanceMode.displayName)
                            .foregroundColor(.secondary)
                    }
                )
            .listRowInsets(.init(top: 0, leading: 0, bottom: MainScreenConstants.adaptiveValue(6), trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }
}


