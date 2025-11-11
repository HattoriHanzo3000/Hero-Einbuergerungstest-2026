import Combine
import Foundation

@MainActor
final class SettingsRegionalViewModel: ObservableObject {
    @Published private(set) var appLanguage: SettingsAppLanguageOption
    @Published private(set) var translationLanguage: SettingsTranslationLanguageOption
    @Published private(set) var translationOptions: [SettingsTranslationLanguageOption]
    @Published private(set) var federalStateName: String
    @Published private(set) var selectedTestDate: Date?

    var currentLocale: Locale {
        languageManager.currentLocale
    }

    private let languageManager: LanguageManager
    private let stateManager: StateManager
    private let onboardingPreferences: OnboardingPreferences
    private let defaults: UserDefaults

    private var cancellables = Set<AnyCancellable>()

    init(
        languageManager: LanguageManager,
        stateManager: StateManager,
        onboardingPreferences: OnboardingPreferences = .shared,
        defaults: UserDefaults = .standard
    ) {
        self.languageManager = languageManager
        self.stateManager = stateManager
        self.onboardingPreferences = onboardingPreferences
        self.defaults = defaults

        let initialAppLanguage = SettingsAppLanguageOption(rawValue: languageManager.currentAppLanguage) ?? .english
        let initialTranslationLanguage = Self.resolveTranslationLanguage(
            languageManager: languageManager,
            currentOption: SettingsTranslationLanguageOption(rawValue: languageManager.currentTranslationLanguage) ?? .german
        )

        self.appLanguage = initialAppLanguage
        self.translationLanguage = initialTranslationLanguage
        self.translationOptions = Self.availableTranslationOptions(excluding: initialAppLanguage)
        self.federalStateName = stateManager.selectedState ?? FederalStateModel.allStates.first?.name ?? "Berlin"

        let initialDate = onboardingPreferences.testDate ?? defaults.object(forKey: UserDefaultsKey.testDateRaw) as? Date
        self.selectedTestDate = initialDate

        bindLanguageManager()
        bindStateManager()
    }

    func setAppLanguage(_ option: SettingsAppLanguageOption) {
        guard option != appLanguage else { return }
        languageManager.setAppLanguage(option.rawValue)
    }

    func setTranslationLanguage(_ option: SettingsTranslationLanguageOption) {
        guard option != translationLanguage else { return }
        languageManager.setTranslationLanguage(option.rawValue)
    }

    func setFederalState(name: String) {
        stateManager.setSelectedState(name)
    }

    func saveTestDate(_ date: Date) {
        selectedTestDate = date
        onboardingPreferences.testDate = date
        onboardingPreferences.testDateDontKnow = false
        defaults.set(date, forKey: UserDefaultsKey.testDateRaw)
    }

    func clearTestDate() {
        selectedTestDate = nil
        onboardingPreferences.testDate = nil
        onboardingPreferences.testDateDontKnow = true
        defaults.removeObject(forKey: UserDefaultsKey.testDateRaw)
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
                self.onboardingPreferences.selectedState = selected
            }
            .store(in: &cancellables)
    }

    private static func availableTranslationOptions(excluding appLanguage: SettingsAppLanguageOption) -> [SettingsTranslationLanguageOption] {
        SettingsTranslationLanguageOption.allCases.filter { $0.rawValue != appLanguage.rawValue }
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

    private enum UserDefaultsKey {
        static let testDateRaw = "selectedTestDate"
    }
}

