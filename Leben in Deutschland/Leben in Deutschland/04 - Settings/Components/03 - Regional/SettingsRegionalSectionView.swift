import SwiftUI

struct SettingsRegionalSectionView: View {
    @ObservedObject var viewModel: SettingsRegionalViewModel

    var body: some View {
        Section {
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
                    ForEach(SettingsAppLanguageOption.allCases) { option in
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
                HapticManager.shared.lightImpact()
            }
        )
    }
}

// MARK: - Translation Language

private struct SettingsTranslationLanguageRow: View {
    @ObservedObject var viewModel: SettingsRegionalViewModel

    var body: some View {
        HStack(spacing: SettingsDesignTokens.Layout.rowSpacing) {
            SettingsIconView(systemName: "book", tint: SettingsDesignTokens.Palette.regional)
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
                HapticManager.shared.lightImpact()
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
                HapticManager.shared.lightImpact()
            }
        )
    }
}

// MARK: - Test Date

private struct SettingsTestDateRow: View {
    @ObservedObject var viewModel: SettingsRegionalViewModel
    @State private var dateValue: Date = Date()
    @State private var isUpdatingFromViewModel = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: SettingsDesignTokens.Layout.rowSpacing) {
                SettingsIconView(systemName: "calendar.badge.clock", tint: SettingsDesignTokens.Palette.regional)
                Text("settings_test_date".localized)
                    .font(.body)
                    .foregroundStyle(.primary)
                Spacer()
                HStack(spacing: 8) {
                    if viewModel.selectedTestDate != nil {
                        datePicker
                    } else {
                        ZStack(alignment: .leading) {
                            datePicker.opacity(0.01)
                            Text("settings_test_date_not_set".localized)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .frame(width: 160, alignment: .leading)
                                .padding(.horizontal, 4)
                                .allowsHitTesting(false)
                        }
                    }
                    if viewModel.selectedTestDate != nil {
                        Button {
                            HapticManager.shared.lightImpact()
                            isUpdatingFromViewModel = true
                            viewModel.clearTestDate()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color.secondary.opacity(0.2), Color.secondary)
                                .imageScale(.medium)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text("CLEAR_DATE".localized))
                    }
                }
            }
            .padding(.vertical, SettingsDesignTokens.Layout.rowVerticalPadding)
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("settings_test_date".localized))
        .accessibilityValue(Text(accessibilityValueDescription))
    }

    private var datePicker: some View {
        DatePicker(
            "",
            selection: Binding(
                get: { dateValue },
                set: { newValue in
                    if isUpdatingFromViewModel {
                        return
                    }
                    dateValue = newValue
                    viewModel.saveTestDate(newValue)
                    HapticManager.shared.lightImpact()
                }
            ),
            in: Date()...,
            displayedComponents: .date
        )
        .datePickerStyle(.compact)
        .labelsHidden()
        .environment(\.locale, viewModel.currentLocale)
        .frame(width: 160)
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
}

#Preview("Regional Section") {
    let languageManager = LanguageManager()
    let stateManager = StateManager()
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

