import SwiftUI

/// Placeholder for the upcoming Settings BETA screen.
struct SettingsBetaView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var stateManager: StateManager
    @EnvironmentObject private var soundManager: SoundManager
    @State private var isHapticsEnabled: Bool = true
    @State private var appearanceSelection: AppearanceOption = .system
    @State private var updateAlert: UpdateAlert?
    @State private var selectedTestDate: Date? = SettingsBetaView.initialTestDate
    @State private var datePickerValue: Date = SettingsBetaView.initialTestDate ?? Date()
    @State private var isClearingTestDate: Bool = false
    @Environment(\.openURL) private var openURL
    
    private let updatesTint = Color.accentColor
    private let premiumTint = Color(red: 0.96, green: 0.78, blue: 0.24)
    private let regionalTint = Color(.systemPurple)
    private let personalisationTint = Color(.systemGreen)
    private let supportTint = Color(.systemOrange)
    private let legalTint = Color(red: 0.16, green: 0.28, blue: 0.47)
    private let resetTint = Color(.systemRed)
    private let latestAvailableVersion = "1.1.5" // TODO: Replace with real remote version source
    private let appStoreURL = URL(string: "https://apps.apple.com/de/app/hero-leben-in-deutschland/id6752272685")
    private let onboardingPreferences = OnboardingPreferences.shared
    private static var initialTestDate: Date? {
        if let preferenceDate = OnboardingPreferences.shared.testDate {
            return preferenceDate
        }
        if let storedDate = UserDefaults.standard.object(forKey: "selectedTestDate") as? Date {
            return storedDate
        }
        return nil
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                // MARK: Version & Updates
                Section {
                    settingsRow(title: "version".localized, systemImage: "info.circle.fill", iconColor: updatesTint)
                    settingsRow(title: "settings_check_updates_button".localized, systemImage: "arrow.down.circle.fill", iconColor: updatesTint, showsChevron: false, action: handleUpdateCheck)
                    settingsRow(title: "settings_open_app_store_button".localized, systemImage: "app.badge.fill", iconColor: updatesTint, showsChevron: false, action: openAppStore)
                }
                
                // MARK: Premium
                Section {
                    settingsRow(title: "settings_premium_title".localized, systemImage: "crown.fill", iconColor: premiumTint)
                }
                
                // MARK: App & Regional Settings
                Section {
                    settingsAppLanguageRow()
                    settingsTranslationLanguageRow()
                    settingsFederalStateRow()
                    settingsTestDateRow()
                }
                
                // MARK: Personalisation
                Section {
                    Toggle(isOn: soundEnabledBinding) {
                        settingsToggleLabel(title: "settings_sound_toggle".localized, systemImage: "speaker.wave.2.fill", iconColor: personalisationTint)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color(.systemGreen)))
                    Toggle(isOn: hapticsEnabledBinding) {
                        settingsToggleLabel(title: "settings_haptics_toggle".localized, systemImage: "iphone.radiowaves.left.and.right", iconColor: personalisationTint)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color(.systemGreen)))
                    settingsAppearanceRow()
                }
                
                // MARK: Support
                Section {
                    settingsRow(title: "settings_contact_button".localized, systemImage: "envelope.fill", iconColor: supportTint, showsChevron: false)
                    settingsRow(title: "settings_faq_button".localized, systemImage: "questionmark.circle.fill", iconColor: supportTint, showsChevron: false)
                    settingsRow(title: "settings_report_bug_button".localized, systemImage: "flag.fill", iconColor: supportTint, showsChevron: false)
                }
                
                // MARK: Legal
                Section {
                    settingsRow(title: "settings_impressum_button".localized, systemImage: "building.2.fill", iconColor: legalTint, showsChevron: false)
                    settingsRow(title: "terms_of_service".localized, systemImage: "doc.text.fill", iconColor: legalTint, showsChevron: false)
                    settingsRow(title: "privacy_policy".localized, systemImage: "lock.fill", iconColor: legalTint, showsChevron: false)
                }
                
                // MARK: Danger Zone
                Section {
                    settingsRow(title: "settings_reset_app".localized, systemImage: "arrow.counterclockwise.circle.fill", iconColor: resetTint, showsChevron: false)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("settings_beta_title".localized)
            .navigationBarTitleDisplayMode(.large)
            .alert(updateAlert?.title ?? "", isPresented: Binding(
                get: { updateAlert != nil },
                set: { isPresented in
                    if !isPresented {
                        updateAlert = nil
                    }
                }
            ), presenting: updateAlert) { alert in
                switch alert.kind {
                case .latest:
                    Button("ok".localized, role: .cancel) {
                        updateAlert = nil
                    }
                case .available:
                    Button("update_now".localized) {
                        if let url = appStoreURL {
                            openURL(url)
                        }
                        updateAlert = nil
                    }
                    Button("update_later".localized, role: .cancel) {
                        updateAlert = nil
                    }
                }
            } message: { alert in
                switch alert.kind {
                case .latest(let current):
                    Text(latestMessage(currentVersion: current))
                case .available(_, let latest):
                    Text(availableMessage(latestVersion: latest))
                }
            }
            .onAppear {
                datePickerValue = selectedTestDate ?? Date()
            }
        }
    }
    
    // MARK: - Private Helpers
    private func settingsRow(title: String, systemImage: String, iconColor: Color, showsChevron: Bool = true, action: (() -> Void)? = nil) -> some View {
        Group {
            if let action {
                Button {
                    HapticManager.shared.lightImpact()
                    action()
                } label: {
                    SettingsRowContent(title: title, systemImage: systemImage, tint: iconColor, showsChevron: showsChevron)
                }
                .buttonStyle(.plain)
            } else if showsChevron {
                NavigationLink {
                    destinationView(title: title)
                } label: {
                    SettingsRowContent(title: title, systemImage: systemImage, tint: iconColor, showsChevron: false)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    HapticManager.shared.lightImpact()
                })
            } else {
                SettingsRowContent(title: title, systemImage: systemImage, tint: iconColor, showsChevron: false)
            }
        }
    }
    
    private func destinationView(title: String) -> some View {
        VersionDetailView(title: title)
    }

    // MARK: - Version Detail View
    private struct VersionDetailView: View {
        let title: String
        @AppStorage("app_version") private var currentVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        
        var body: some View {
            List {
                Section("settings_current_version".localized) {
                    HStack {
                        Text("settings_installed_version".localized)
                        Spacer()
                        Text(currentVersion)
                            .font(.body.weight(.medium))
                            .foregroundStyle(.primary)
                    }
                }
                
                Section("settings_latest_updates".localized) {
                    Text("settings_version_updates".localized)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Row Content
    private struct SettingsRowContent: View {
        let title: String
        let systemImage: String
        let tint: Color
        let showsChevron: Bool
        
        var body: some View {
            HStack(spacing: 14) {
                SettingsIconView(systemImage: systemImage, tint: tint)
                    .accessibilityHidden(true)
                Text(title)
                Spacer()
                if showsChevron {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }
            }
            .contentShape(Rectangle())
        }
    }
    
    private func settingsToggleLabel(
        title: String,
        systemImage: String,
        iconColor: Color,
        trailingText: String? = nil
    ) -> some View {
        HStack(spacing: 14) {
            SettingsIconView(systemImage: systemImage, tint: iconColor)
                .accessibilityHidden(true)
            Text(title)
            Spacer()
            if let trailingText {
                Text(trailingText)
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func settingsAppearanceRow() -> some View {
        HStack(spacing: 14) {
            SettingsIconView(systemImage: "sun.min", tint: personalisationTint)
                .accessibilityHidden(true)
            Text("settings_appearance_title".localized)
            Spacer()
            Menu {
                Picker(selection: $appearanceSelection.animation(.easeInOut)) {
                    ForEach(AppearanceOption.allCases, id: \.self) { option in
                        Text(option.displayName).tag(option)
                    }
                } label: {
                    EmptyView()
                }
            } label: {
                HStack(spacing: 6) {
                    Text(appearanceSelection.displayName)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }
            }
            .menuStyle(.button)
            .contentShape(Capsule())
        }
    }
    
    // MARK: - App Language
    private func settingsAppLanguageRow() -> some View {
        HStack(spacing: 14) {
            SettingsIconView(systemImage: "globe", tint: regionalTint)
                .accessibilityHidden(true)
            Text("settings_app_language".localized)
            Spacer()
            Menu {
                Picker(selection: appLanguageBinding.animation(.easeInOut)) {
                    ForEach(AppLanguageOption.allCases) { option in
                        Text(option.displayName).tag(option)
                    }
                } label: {
                    EmptyView()
                }
            } label: {
                HStack(spacing: 6) {
                    Text(currentAppLanguageOption.displayName)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .accessibilityHidden(true)
                }
                .contentShape(Rectangle())
            }
            .menuStyle(.button)
            .contentShape(Capsule())
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text("settings_app_language".localized))
            .accessibilityValue(Text(currentAppLanguageOption.displayName))
        }
    }

    private var currentAppLanguageOption: AppLanguageOption {
        AppLanguageOption(rawValue: languageManager.currentAppLanguage) ?? .english
    }

    private var appLanguageBinding: Binding<AppLanguageOption> {
        Binding(
            get: { currentAppLanguageOption },
            set: { option in
                languageManager.setAppLanguage(option.rawValue)
            }
        )
    }

    // MARK: - Translation Language
    private func settingsTranslationLanguageRow() -> some View {
        HStack(spacing: 14) {
            SettingsIconView(systemImage: "book", tint: regionalTint)
                .accessibilityHidden(true)
            Text("settings_translation_language".localized)
            Spacer()
            Menu {
                Picker(selection: translationLanguageBinding.animation(.easeInOut)) {
                    ForEach(availableTranslationOptions) { option in
                        Text(option.displayName).tag(option)
                    }
                } label: {
                    EmptyView()
                }
            } label: {
                HStack(spacing: 6) {
                    Text(currentTranslationLanguageOption.displayName)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .accessibilityHidden(true)
                }
                .contentShape(Rectangle())
            }
            .menuStyle(.button)
            .contentShape(Capsule())
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text("settings_translation_language".localized))
            .accessibilityValue(Text(currentTranslationLanguageOption.displayName))
        }
    }

    private var currentTranslationLanguageOption: TranslationLanguageOption {
        let selection = TranslationLanguageOption(rawValue: languageManager.currentTranslationLanguage) ?? .german
        if selection.rawValue == languageManager.currentAppLanguage,
           let fallback = availableTranslationOptions.first {
            DispatchQueue.main.async {
                languageManager.setTranslationLanguage(fallback.rawValue)
            }
            return fallback
        }
        return selection
    }

    private var availableTranslationOptions: [TranslationLanguageOption] {
        TranslationLanguageOption.allCases.filter { $0.rawValue != languageManager.currentAppLanguage }
    }

    private var translationLanguageBinding: Binding<TranslationLanguageOption> {
        Binding(
            get: { currentTranslationLanguageOption },
            set: { option in
                languageManager.setTranslationLanguage(option.rawValue)
            }
        )
    }

    private var soundEnabledBinding: Binding<Bool> {
        Binding(
            get: { soundManager.isSoundEnabled },
            set: { value in
                HapticManager.shared.lightImpact()
                soundManager.setSoundEnabled(value)
            }
        )
    }

    private var hapticsEnabledBinding: Binding<Bool> {
        Binding(
            get: {
                UserDefaults.standard.object(forKey: "vibration_enabled") as? Bool ?? true
            },
            set: { value in
                UserDefaults.standard.set(value, forKey: "vibration_enabled")
                HapticManager.shared.lightImpact()
            }
        )
    }

    private func settingsTestDateRow() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 14) {
                SettingsIconView(systemImage: "calendar.badge.clock", tint: regionalTint)
                    .accessibilityHidden(true)
                Text("settings_test_date".localized)
                Spacer()
                HStack(spacing: 8) {
                    ZStack(alignment: .leading) {
                        if selectedTestDate != nil {
                            DatePicker(
                                "",
                                selection: $datePickerValue,
                                in: Date()...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .environment(\.locale, languageManager.currentLocale)
                            .onChange(of: datePickerValue) { newValue in
                                guard !isClearingTestDate else {
                                    isClearingTestDate = false
                                    return
                                }
                                saveTestDate(newValue)
                            }
                        } else {
                            DatePicker(
                                "",
                                selection: $datePickerValue,
                                in: Date()...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .environment(\.locale, languageManager.currentLocale)
                            .foregroundColor(.clear)
                            .accentColor(.clear)
                            .opacity(0.01)
                            .frame(width: 150)
                            .onChange(of: datePickerValue) { newValue in
                                guard !isClearingTestDate else {
                                    isClearingTestDate = false
                                    return
                                }
                                saveTestDate(newValue)
                            }

                            Text("settings_test_date_not_set".localized)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .frame(width: 150, alignment: .leading)
                                .padding(.horizontal, 4)
                                .allowsHitTesting(false)
                        }
                    }
                    .contentShape(Rectangle())

                    if selectedTestDate != nil {
                        Button {
                            HapticManager.shared.lightImpact()
                            clearTestDate()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color.secondary.opacity(0.2), Color.secondary)
                                .imageScale(.medium)
                                .accessibilityLabel("CLEAR_DATE".localized)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Federal State
    private func settingsFederalStateRow() -> some View {
        HStack(spacing: 14) {
            SettingsIconView(systemImage: "map.fill", tint: regionalTint)
                .accessibilityHidden(true)
            Text("settings_federal_state".localized)
            Spacer()
            Menu {
                Picker(selection: federalStateBinding.animation(.easeInOut)) {
                    ForEach(FederalStateModel.allStates, id: \.name) { state in
                        Text(localizedStateName(state.name)).tag(state.name)
                    }
                } label: {
                    EmptyView()
                }
            } label: {
                HStack(spacing: 6) {
                    Text(truncatedFederalStateDisplayName)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .accessibilityHidden(true)
                }
                .contentShape(Rectangle())
            }
            .menuStyle(.button)
            .contentShape(Capsule())
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text("settings_federal_state".localized))
            .accessibilityValue(Text(currentFederalStateDisplayName))
        }
    }

    private var currentFederalStateDisplayName: String {
        let current = stateManager.selectedState ?? FederalStateModel.allStates.first?.name ?? "Berlin"
        return localizedStateName(current)
    }

    private var truncatedFederalStateDisplayName: String {
        let display = currentFederalStateDisplayName
        guard display.count > 12 else { return display }
        let index = display.index(display.startIndex, offsetBy: 12)
        return String(display[..<index]).trimmingCharacters(in: .whitespacesAndNewlines) + "…"
    }

    private var federalStateBinding: Binding<String> {
        Binding(
            get: { stateManager.selectedState ?? FederalStateModel.allStates.first?.name ?? "Berlin" },
            set: { newValue in
                stateManager.setSelectedState(newValue)
            }
        )
    }

    private func localizedStateName(_ name: String) -> String {
        name.localized(for: languageManager.currentAppLanguage)
    }

    private func saveTestDate(_ date: Date) {
        selectedTestDate = date
        datePickerValue = date
        onboardingPreferences.testDate = date
        onboardingPreferences.testDateDontKnow = false
        UserDefaults.standard.set(date, forKey: "selectedTestDate")
    }

    private func clearTestDate() {
        isClearingTestDate = true
        selectedTestDate = nil
        datePickerValue = Date()
        onboardingPreferences.testDate = nil
        onboardingPreferences.testDateDontKnow = true
        UserDefaults.standard.removeObject(forKey: "selectedTestDate")
    }

    // MARK: - Update Handling
    private func handleUpdateCheck() {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let comparison = compareVersions(currentVersion, latestAvailableVersion)
        if comparison != .orderedAscending {
            updateAlert = UpdateAlert(kind: .latest(currentVersion: currentVersion))
        } else {
            updateAlert = UpdateAlert(kind: .available(currentVersion: currentVersion, latestVersion: latestAvailableVersion))
        }
    }
    
    // MARK: - Alert Messaging
    private func latestMessage(currentVersion: String) -> String {
        let base = "update_latest_message".localized
        let installed = String(format: "%@: %@", "settings_installed_version".localized, currentVersion)
        return [base, installed].joined(separator: "\n\n")
    }
    
    private func availableMessage(latestVersion: String) -> String {
        String(format: "update_message_with_version".localized, latestVersion)
    }

    private func openAppStore() {
        guard let url = appStoreURL else { return }
        openURL(url)
    }
    
    private func compareVersions(_ lhs: String, _ rhs: String) -> ComparisonResult {
        let lhsComponents = lhs.split(separator: ".").map { Int($0) ?? 0 }
        let rhsComponents = rhs.split(separator: ".").map { Int($0) ?? 0 }
        let maxCount = max(lhsComponents.count, rhsComponents.count)
        for index in 0..<maxCount {
            let left = index < lhsComponents.count ? lhsComponents[index] : 0
            let right = index < rhsComponents.count ? rhsComponents[index] : 0
            if left < right { return .orderedAscending }
            if left > right { return .orderedDescending }
        }
        return .orderedSame
    }

    // MARK: - Appearance Options
    private enum AppearanceOption: CaseIterable {
        case system
        case dark
        case light
        
        var displayName: String {
            switch self {
            case .system:
                return "settings_appearance_system".localized
            case .dark:
                return "settings_appearance_dark".localized
            case .light:
                return "settings_appearance_light".localized
            }
        }
    }

    // MARK: - App Language Options
    private enum AppLanguageOption: String, CaseIterable, Identifiable {
        case english = "en"
        case german = "de"
        case russian = "ru"
        case ukrainian = "uk"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .english:
                return "settings_language_option_english".localized
            case .german:
                return "settings_language_option_german".localized
            case .russian:
                return "settings_language_option_russian".localized
            case .ukrainian:
                return "settings_language_option_ukrainian".localized
            }
        }
    }

    // MARK: - Translation Language Options
    private enum TranslationLanguageOption: String, CaseIterable, Identifiable {
        case english = "en"
        case german = "de"
        case russian = "ru"
        case ukrainian = "uk"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .english:
                return "settings_language_option_english".localized
            case .german:
                return "settings_language_option_german".localized
            case .russian:
                return "settings_language_option_russian".localized
            case .ukrainian:
                return "settings_language_option_ukrainian".localized
            }
        }
    }

    // MARK: - Test Date Options
    private enum TestDateOption: String, CaseIterable, Identifiable {
        case today = "today"
        case tomorrow = "tomorrow"
        case nextWeek = "next_week"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .today:
                return "settings_test_date_today".localized
            case .tomorrow:
                return "settings_test_date_tomorrow".localized
            case .nextWeek:
                return "settings_test_date_next_week".localized
            }
        }
    }
}

// MARK: - Settings Icon View
private struct SettingsIconView: View {
    let systemImage: String
    let tint: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(tint.opacity(0.2))
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(tint.opacity(0.35), lineWidth: 0.6)
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(tint)
        }
        .frame(width: 24, height: 24)
    }
}

// MARK: - Update Alert Model
private struct UpdateAlert: Identifiable {
    enum Kind {
        case latest(currentVersion: String)
        case available(currentVersion: String, latestVersion: String)
    }
    let kind: Kind
    var id: String {
        switch kind {
        case .latest(let current):
            return "latest-\(current)"
        case .available(let current, let latest):
            return "available-\(current)-\(latest)"
        }
    }
    
    var title: String {
        switch kind {
        case .latest:
            return "update_latest_title".localized
        case .available:
            return "update_title".localized
        }
    }
    
    private func latestMessage(currentVersion: String) -> String {
        let base = "update_latest_message".localized
        let installed = String(format: "%@: %@", "settings_installed_version".localized, currentVersion)
        return [base, installed].joined(separator: "\n\n")
    }
    
    private func availableMessage(latestVersion: String) -> String {
        String(format: "update_message_with_version".localized, latestVersion)
    }
}

// MARK: - Preview
#Preview("Settings BETA") {
    SettingsBetaView()
        .environmentObject(LanguageManager())
        .environmentObject(StateManager())
        .environmentObject(SoundManager.shared)
}

