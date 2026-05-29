import SwiftUI

struct SettingsPersonalisationSectionView: View {
    @ObservedObject var viewModel: SettingsPersonalisationViewModel

    var body: some View {
        Section("settings_personalisation_title".localized) {
            Toggle(isOn: hapticsBinding.animation(.easeInOut(duration: 0.15))) {
                SettingsToggleRowLabel(
                    title: "settings_haptics_toggle".localized,
                    iconSystemName: "hand.tap.fill",
                    tint: .purple
                )
            }
            .toggleStyle(.switch)
            .tint(.green)

            SettingsAppearanceRow(
                selection: Binding(
                    get: { viewModel.appearanceMode },
                    set: { mode in
                        viewModel.setAppearance(mode)
                    }
                )
            )
        }
    }

    private var hapticsBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isHapticsEnabled },
            set: { isOn in
                viewModel.setHapticsEnabled(isOn)
            }
        )
    }
}

private struct SettingsAppearanceRow: View {
    @Binding var selection: AppearanceMode

    var body: some View {
        HStack(spacing: SettingsDesignTokens.Layout.rowSpacing) {
            SettingsIconView(
                systemName: "paintbrush.fill",
                tint: .pink
            )
            Text("settings_appearance_title".localized)
                .font(.body)
                .foregroundStyle(.primary)
            Spacer()
            Menu {
                Picker(
                    "settings_appearance_title".localized,
                    selection: $selection.animation(.easeInOut(duration: 0.2))
                ) {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.inline)
            } label: {
                SettingsTrailingValueLabel(
                    text: selection.displayName,
                    systemImage: "chevron.up.chevron.down"
                )
            }
            .menuStyle(.button)
            .tint(SettingsDesignTokens.Palette.trailingValue)
        }
        .padding(.vertical, SettingsDesignTokens.Layout.rowVerticalPadding)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("settings_appearance_title".localized))
        .accessibilityValue(Text(selection.displayName))
    }
}

#Preview("Personalisation Section") {
    let viewModel = SettingsPersonalisationViewModel(
        soundManager: SoundManager.shared
    )
    return NavigationStack {
        List {
            SettingsPersonalisationSectionView(viewModel: viewModel)
        }
        .listStyle(.insetGrouped)
    }
    .environmentObject(LanguageManager())
    .environmentObject(StateManager.shared)
    .environmentObject(SoundManager.shared)
}

