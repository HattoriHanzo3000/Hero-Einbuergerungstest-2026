import SwiftUI

struct SettingsRegionalSectionView: View {
    @ObservedObject var viewModel: SettingsRegionalViewModel

    var body: some View {
        Section("settings_regional_title".localized) {
            SettingsAppLanguageRow(viewModel: viewModel)
            SettingsTranslationLanguageRow(viewModel: viewModel)
            SettingsFederalStateRow(viewModel: viewModel)
            SettingsTestDateRow(viewModel: viewModel)
        }
    }
}

// MARK: - App Language

private struct SettingsAppLanguageRow: View {
    @ObservedObject var viewModel: SettingsRegionalViewModel

    var body: some View {
        HStack(spacing: SettingsDesignTokens.Layout.rowSpacing) {
            SettingsIconView(systemName: "globe", tint: SettingsDesignTokens.Palette.regional)
            Text("settings_app_language".localized)
                .font(.body)
                .foregroundStyle(.primary)
            Spacer()
            Menu {
                Picker(
                    "settings_app_language".localized,
                    selection: appLanguageBinding.animation(.easeInOut(duration: 0.2))
                ) {
                    ForEach(SettingsAppLanguageOption.displayCases) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.inline)
            } label: {
                SettingsTrailingValueLabel(
                    text: viewModel.appLanguage.displayName,
                    systemImage: "chevron.up.chevron.down"
                )
            }
            .menuStyle(.button)
            .tint(SettingsDesignTokens.Palette.trailingValue)
        }
        .padding(.vertical, SettingsDesignTokens.Layout.rowVerticalPadding)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("settings_app_language".localized))
        .accessibilityValue(Text(viewModel.appLanguage.displayName))
    }

    private var appLanguageBinding: Binding<SettingsAppLanguageOption> {
        Binding(
            get: { viewModel.appLanguage },
            set: { option in
                viewModel.setAppLanguage(option)
            }
        )
    }
}

// MARK: - Translation Language

private struct SettingsTranslationLanguageRow: View {
    @ObservedObject var viewModel: SettingsRegionalViewModel

    var body: some View {
        HStack(spacing: SettingsDesignTokens.Layout.rowSpacing) {
            SettingsIconView(systemName: "translate", tint: SettingsDesignTokens.Palette.regional)
            Text("settings_translation_language".localized)
                .font(.body)
                .foregroundStyle(.primary)
            Spacer()
            Menu {
                Picker(
                    "settings_translation_language".localized,
                    selection: translationBinding.animation(.easeInOut(duration: 0.2))
                ) {
                    ForEach(viewModel.translationOptions) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(.inline)
            } label: {
                SettingsTrailingValueLabel(
                    text: viewModel.translationLanguage.displayName,
                    systemImage: "chevron.up.chevron.down"
                )
            }
            .menuStyle(.button)
            .tint(SettingsDesignTokens.Palette.trailingValue)
        }
        .padding(.vertical, SettingsDesignTokens.Layout.rowVerticalPadding)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("settings_translation_language".localized))
        .accessibilityValue(Text(viewModel.translationLanguage.displayName))
    }

    private var translationBinding: Binding<SettingsTranslationLanguageOption> {
        Binding(
            get: { viewModel.translationLanguage },
            set: { option in
                viewModel.setTranslationLanguage(option)
            }
        )
    }
}

// MARK: - Federal State

private struct SettingsFederalStateRow: View {
    @ObservedObject var viewModel: SettingsRegionalViewModel

    var body: some View {
        HStack(spacing: SettingsDesignTokens.Layout.rowSpacing) {
            SettingsIconView(systemName: "map.fill", tint: SettingsDesignTokens.Palette.regional)
            Text("settings_federal_state".localized)
                .font(.body)
                .foregroundStyle(.primary)
            Spacer()
            Menu {
                Picker(
                    "settings_federal_state".localized,
                    selection: stateBinding.animation(.easeInOut(duration: 0.2))
                ) {
                    ForEach(FederalStateModel.allStates, id: \.name) { state in
                        Text(viewModel.localizedStateName(state.name)).tag(state.name)
                    }
                }
                .pickerStyle(.inline)
            } label: {
                SettingsTrailingValueLabel(
                    text: viewModel.truncatedFederalStateDisplayName(),
                    systemImage: "chevron.up.chevron.down"
                )
            }
            .menuStyle(.button)
            .tint(SettingsDesignTokens.Palette.trailingValue)
        }
        .padding(.vertical, SettingsDesignTokens.Layout.rowVerticalPadding)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("settings_federal_state".localized))
        .accessibilityValue(Text(viewModel.localizedStateName(viewModel.federalStateName)))
    }

    private var stateBinding: Binding<String> {
        Binding(
            get: { viewModel.federalStateName },
            set: { name in
                viewModel.setFederalState(name: name)
            }
        )
    }
}

// MARK: - Test Date

private struct SettingsTestDateRow: View {
    @ObservedObject var viewModel: SettingsRegionalViewModel
    @State private var dateValue: Date = Date()
    @State private var isUpdatingFromViewModel = false
    @State private var showDateTooFarAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: toggleBinding.animation(.easeInOut(duration: 0.2))) {
                HStack(spacing: SettingsDesignTokens.Layout.rowSpacing) {
                    SettingsIconView(systemName: "calendar.badge.clock", tint: SettingsDesignTokens.Palette.regional)
                    Text("settings_test_date".localized)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
            }
            .toggleStyle(.switch)
            .tint(.green)
            .padding(.vertical, SettingsDesignTokens.Layout.rowVerticalPadding)
            .accessibilityLabel(Text("settings_test_date".localized))
            .accessibilityValue(Text(accessibilityValueDescription))
            if viewModel.isTestDateTrackingEnabled {
                Divider()
                    .padding(
                        .leading,
                        SettingsDesignTokens.Icon.containerSize + (SettingsDesignTokens.Layout.rowSpacing * 2)
                    )

                HStack(spacing: SettingsDesignTokens.Layout.rowSpacing) {
                    SettingsIconView(systemName: "1.calendar", tint: SettingsDesignTokens.Palette.regional)
                    Text("settings_test_date_not_set".localized)
                        .font(.body)
                        .foregroundStyle(.primary)
                    Spacer(minLength: 0)
                    DatePicker(
                        "",
                        selection: dateBinding,
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .environment(\.locale, viewModel.currentLocale)
                }
                .padding(.vertical, SettingsDesignTokens.Layout.rowVerticalPadding)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(Text("settings_test_date".localized))
                .accessibilityValue(Text(accessibilityValueDescription))
            }
        }
        .onAppear {
            isUpdatingFromViewModel = true
            dateValue = viewModel.selectedTestDate ?? Date()
            isUpdatingFromViewModel = false
        }
        .onReceive(viewModel.$selectedTestDate) { newValue in
            isUpdatingFromViewModel = true
            dateValue = newValue ?? Date()
            isUpdatingFromViewModel = false
        }
        .alert("date_too_far_title".localized, isPresented: $showDateTooFarAlert) {
            Button("ok_button".localized) {
                HapticManager.shared.lightImpact()
                isUpdatingFromViewModel = true
                dateValue = viewModel.selectedTestDate ?? Date()
                isUpdatingFromViewModel = false
            }
        } message: {
            Text("date_too_far_message".localized)
        }
    }

    private var toggleBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isTestDateTrackingEnabled },
            set: { isEnabled in
                if isEnabled {
                    viewModel.activateTestDateTracking()
                    dateValue = viewModel.selectedTestDate ?? Date()
                } else {
                    HapticManager.shared.lightImpact()
                    viewModel.clearTestDate()
                }
            }
        )
    }

    private var accessibilityValueDescription: String {
        if let date = viewModel.selectedTestDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.locale = viewModel.currentLocale
            return formatter.string(from: date)
        }
        return "settings_test_date_not_set".localized
    }

    private var dateBinding: Binding<Date> {
        Binding(
            get: { dateValue },
            set: { newValue in
                if isUpdatingFromViewModel { return }
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let selectedDay = calendar.startOfDay(for: newValue)
                let days = calendar.dateComponents([.day], from: today, to: selectedDay).day ?? 0
                if days > 365 {
                    // Temporarily show the selected date, but do not save it.
                    dateValue = newValue
                    showDateTooFarAlert = true
                    return
                }
                dateValue = newValue
                viewModel.saveTestDate(newValue)
            }
        )
    }
}

#Preview("Regional Section") {
    let languageManager = LanguageManager()
    let stateManager = StateManager.shared
    let viewModel = SettingsRegionalViewModel(
        languageManager: languageManager,
        stateManager: stateManager
    )
    return NavigationStack {
        List {
            SettingsRegionalSectionView(viewModel: viewModel)
        }
        .listStyle(.insetGrouped)
    }
    .environmentObject(languageManager)
    .environmentObject(stateManager)
}

