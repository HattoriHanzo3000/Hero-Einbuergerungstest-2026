import Combine
import Foundation

@MainActor
final class SettingsRegionalViewModel: ObservableObject {
    @Published private(set) var appLanguage: SettingsAppLanguageOption
    @Published private(set) var translationLanguage: SettingsTranslationLanguageOption
    @Published private(set) var translationOptions: [SettingsTranslationLanguageOption]
    @Published var federalStateName: String
    @Published private(set) var selectedTestDate: Date?
    @Published private(set) var isTestDateTrackingEnabled: Bool
    @Published var showStateChangeWarning: Bool = false
    @Published var showAppLanguageChangeWarning: Bool = false
    @Published var showTranslationLanguageChangeWarning: Bool = false

    var currentLocale: Locale {
        languageManager.currentLocale
    }

    private let languageManager: LanguageManager
    private let stateManager: StateManager
    private let onboardingPreferences: OnboardingPreferences
    private let defaults: UserDefaults

    private var cancellables = Set<AnyCancellable>()
    private var originalState: String?
    private var pendingStateName: String?
    private var pendingAppLanguage: SettingsAppLanguageOption?
    private var pendingTranslationLanguage: SettingsTranslationLanguageOption?

    init(
        languageManager: LanguageManager,
        stateManager: StateManager,
        onboardingPreferences: OnboardingPreferences? = nil,
        defaults: UserDefaults = .standard
    ) {
        self.languageManager = languageManager
        self.stateManager = stateManager
        self.onboardingPreferences = onboardingPreferences ?? OnboardingPreferences.shared
        self.defaults = defaults

        var initialAppLanguage = SettingsAppLanguageOption(rawValue: languageManager.currentAppLanguage) ?? .english
        // Migrate away from Ukrainian if it's disabled
        if initialAppLanguage == .ukrainian {
            initialAppLanguage = .english
            languageManager.setAppLanguage("en")
        }
        var initialTranslationLanguage = SettingsTranslationLanguageOption(rawValue: languageManager.currentTranslationLanguage) ?? .german
        if initialTranslationLanguage == .ukrainian {
            initialTranslationLanguage = .german
            languageManager.setTranslationLanguage("de")
        }
        initialTranslationLanguage = Self.resolveTranslationLanguage(
            languageManager: languageManager,
            currentOption: initialTranslationLanguage
        )

        self.appLanguage = initialAppLanguage
        self.translationLanguage = initialTranslationLanguage
        self.translationOptions = Self.availableTranslationOptions(excluding: initialAppLanguage)
        let initialState = self.onboardingPreferences.selectedState ?? stateManager.selectedState ?? FederalStateModel.allStates.first?.name ?? "Berlin"
        self.federalStateName = initialState
        self.originalState = self.onboardingPreferences.selectedState ?? stateManager.selectedState ?? initialState

        let initialDate = self.onboardingPreferences.testDate ?? defaults.object(forKey: UserDefaultsKey.testDateRaw) as? Date
        self.selectedTestDate = initialDate
        self.isTestDateTrackingEnabled = initialDate != nil

        bindLanguageManager()
        bindStateManager()
    }

    func setAppLanguage(_ option: SettingsAppLanguageOption) {
        guard option != appLanguage else { return }
        pendingAppLanguage = option
        showAppLanguageChangeWarning = true
    }

    func setTranslationLanguage(_ option: SettingsTranslationLanguageOption) {
        guard option != translationLanguage else { return }
        pendingTranslationLanguage = option
        showTranslationLanguageChangeWarning = true
    }

    func cancelPendingAppLanguageChange() {
        HapticManager.shared.lightImpact()
        pendingAppLanguage = nil
        showAppLanguageChangeWarning = false
    }

    func confirmPendingAppLanguageChange() {
        guard let option = pendingAppLanguage else {
            showAppLanguageChangeWarning = false
            return
        }
        HapticManager.shared.lightImpact()
        pendingAppLanguage = nil
        showAppLanguageChangeWarning = false
        languageManager.isApplyingLanguageChange = true
        languageManager.setAppLanguage(option.rawValue)
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            languageManager.isApplyingLanguageChange = false
        }
    }

    func cancelPendingTranslationLanguageChange() {
        HapticManager.shared.lightImpact()
        pendingTranslationLanguage = nil
        showTranslationLanguageChangeWarning = false
    }

    func confirmPendingTranslationLanguageChange() {
        guard let option = pendingTranslationLanguage else {
            showTranslationLanguageChangeWarning = false
            return
        }
        HapticManager.shared.lightImpact()
        pendingTranslationLanguage = nil
        showTranslationLanguageChangeWarning = false
        languageManager.isApplyingLanguageChange = true
        languageManager.setTranslationLanguage(option.rawValue)
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            languageManager.isApplyingLanguageChange = false
        }
    }

    func setFederalState(name: String) {
        HapticManager.shared.lightImpact()
        
        guard name != stateManager.selectedState else {
            federalStateName = name
            return
        }
        
        pendingStateName = name
        federalStateName = name
        showStateChangeWarning = true
    }

    func saveTestDate(_ date: Date) {
        selectedTestDate = date
        isTestDateTrackingEnabled = true
        self.onboardingPreferences.testDate = date
        self.onboardingPreferences.testDateDontKnow = false
        defaults.set(date, forKey: UserDefaultsKey.testDateRaw)
    }

    func clearTestDate() {
        selectedTestDate = nil
        isTestDateTrackingEnabled = false
        self.onboardingPreferences.testDate = nil
        self.onboardingPreferences.testDateDontKnow = true
        defaults.removeObject(forKey: UserDefaultsKey.testDateRaw)
    }

    func activateTestDateTracking() {
        HapticManager.shared.lightImpact()
        let dateToPersist = selectedTestDate ?? Date()
        saveTestDate(dateToPersist)
    }

    func localizedStateName(_ name: String) -> String {
        name.localized(for: languageManager.currentAppLanguage)
    }

    func truncatedFederalStateDisplayName(maxLength: Int = 7) -> String {
        let localized = localizedStateName(federalStateName)
        guard localized.count > maxLength else { return localized }
        let index = localized.index(localized.startIndex, offsetBy: max(0, maxLength - 1))
        return String(localized[..<index]).trimmingCharacters(in: .whitespacesAndNewlines) + "…"
    }

    func cancelPendingStateChange() {
        HapticManager.shared.lightImpact()
        showStateChangeWarning = false
        pendingStateName = nil
        federalStateName = stateManager.selectedState ?? originalState ?? federalStateName
    }

    func confirmPendingStateChange() {
        guard let pendingStateName else {
            showStateChangeWarning = false
            return
        }

        HapticManager.shared.heavyImpact()
        applyStateChange(name: pendingStateName, shouldResetProgress: true)
        showStateChangeWarning = false
    }

    private func bindLanguageManager() {
        languageManager.$currentAppLanguage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self, let option = SettingsAppLanguageOption(rawValue: newValue) else { return }
                self.appLanguage = option
                self.translationOptions = Self.availableTranslationOptions(excluding: option)
                if self.translationOptions.contains(self.translationLanguage) == false,
                   let fallback = self.translationOptions.first {
                    self.setTranslationLanguage(fallback)
                }
            }
            .store(in: &cancellables)

        languageManager.$currentTranslationLanguage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self, let option = SettingsTranslationLanguageOption(rawValue: newValue) else { return }
                self.translationLanguage = option
                self.onboardingPreferences.translationLanguageCode = newValue
                self.onboardingPreferences.translationSelected = true
            }
            .store(in: &cancellables)
    }

    private func bindStateManager() {
        stateManager.$selectedState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self else { return }
                let selected = newValue ?? FederalStateModel.allStates.first?.name ?? "Berlin"
                self.federalStateName = selected
                self.originalState = selected
                self.onboardingPreferences.selectedState = selected
            }
            .store(in: &cancellables)
    }

    private static func availableTranslationOptions(excluding appLanguage: SettingsAppLanguageOption) -> [SettingsTranslationLanguageOption] {
        SettingsTranslationLanguageOption.displayCases.filter { $0.rawValue != appLanguage.rawValue }
    }

    private static func resolveTranslationLanguage(
        languageManager: LanguageManager,
        currentOption: SettingsTranslationLanguageOption
    ) -> SettingsTranslationLanguageOption {
        if currentOption.rawValue == languageManager.currentAppLanguage,
           let fallback = availableTranslationOptions(excluding: SettingsAppLanguageOption(rawValue: languageManager.currentAppLanguage) ?? .english).first {
            languageManager.setTranslationLanguage(fallback.rawValue)
            return fallback
        }
        return currentOption
    }

    private func applyStateChange(name: String, shouldResetProgress: Bool) {
        if shouldResetProgress {
            FederalStateProgressResetService.reset()
        }

        stateManager.setSelectedState(name)
        originalState = name
        federalStateName = name
        pendingStateName = nil
        self.onboardingPreferences.selectedState = name
    }

    private enum UserDefaultsKey {
        static let testDateRaw = "selectedTestDate"
    }
}

