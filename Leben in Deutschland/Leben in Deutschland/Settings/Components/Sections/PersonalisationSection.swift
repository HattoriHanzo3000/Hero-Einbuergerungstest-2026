import SwiftUI

// Personalisation section component (Sound, Vibration, Appearance)
struct PersonalisationSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Section title
            HStack {
                Text("settings_personalisation_title".localized)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Sound Toggle
                SettingsButton(
                    icon: "speaker.wave.2.fill",
                    title: "settings_sound_button".localized,
                    backgroundColor: viewModel.isSoundEnabled ? Color.blue.opacity(0.2) : Color(.systemGray5),
                    action: {
                        viewModel.toggleSound()
                    },
                    trailingContent: {
                        Text(viewModel.isSoundEnabled ? "on".localized : "off".localized)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                )
                
                // Vibration Toggle
                SettingsButton(
                    icon: "iphone.radiowaves.left.and.right",
                    title: "settings_vibration_button".localized,
                    backgroundColor: viewModel.isVibrationEnabled ? Color.blue.opacity(0.2) : Color(.systemGray5),
                    action: {
                        viewModel.toggleVibration()
                    },
                    trailingContent: {
                        Text(viewModel.isVibrationEnabled ? "on".localized : "off".localized)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                )
                
                // Appearance Mode
                SettingsButton(
                    icon: "paintbrush.fill",
                    title: "settings_appearance".localized,
                    action: {
                        viewModel.cycleAppearance()
                    },
                    trailingContent: {
                        Text(viewModel.appearanceMode.displayName)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}


