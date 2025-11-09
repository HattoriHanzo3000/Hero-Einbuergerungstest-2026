import SwiftUI

// Personalisation section component (Sound, Vibration, Appearance)
struct PersonalisationSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        SectionContainer(title: "settings_personalisation_title") {
            // MARK: - Buttons
            VStack(spacing: 12) {
                // MARK: - Sound Toggle
                SettingsButton(
                    icon: "speaker.wave.2.fill",
                    title: "settings_sound_button".localized,
                    backgroundColor: viewModel.isSoundEnabled ? Color.blue.opacity(0.2) : Color(.systemGray5),
                    action: {
                        viewModel.toggleSound()
                    },
                    trailingContent: {
                        Text(viewModel.isSoundEnabled ? "on".localized : "off".localized)
                            .font(.system(.body, design: .rounded).weight(.medium))
                            .foregroundColor(.secondary)
                    }
                )
                
                // MARK: - Vibration Toggle
                SettingsButton(
                    icon: "iphone.radiowaves.left.and.right",
                    title: "settings_vibration_button".localized,
                    backgroundColor: viewModel.isVibrationEnabled ? Color.blue.opacity(0.2) : Color(.systemGray5),
                    action: {
                        viewModel.toggleVibration()
                    },
                    trailingContent: {
                        Text(viewModel.isVibrationEnabled ? "on".localized : "off".localized)
                            .font(.system(.body, design: .rounded).weight(.medium))
                            .foregroundColor(.secondary)
                    }
                )
                
                // MARK: - Appearance Mode
                SettingsButton(
                    icon: "paintbrush.fill",
                    title: "settings_appearance".localized,
                    action: {
                        viewModel.cycleAppearance()
                    },
                    trailingContent: {
                        Text(viewModel.appearanceMode.displayName)
                            .font(.system(.body, design: .rounded).weight(.medium))
                            .foregroundColor(.secondary)
                    }
                )
            }
        }
    }
}


