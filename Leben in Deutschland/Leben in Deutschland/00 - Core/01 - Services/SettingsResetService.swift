import Foundation

@MainActor
protocol SettingsResetServicing {
    func performReset(
        soundManager: SoundManager,
        languageManager: LanguageManager,
        stateManager: StateManager,
        onboardingPreferences: OnboardingPreferences
    )
}

/// Handles destructive reset actions from the Settings dashboard.
@MainActor
final class SettingsResetService: SettingsResetServicing {
    static let shared = SettingsResetService()

    private let defaults: UserDefaults
    private let answersService: AnswersService
    private let categoriesStateService: CategoriesStateService

    private init(
        defaults: UserDefaults = .standard,
        answersService: AnswersService? = nil,
        categoriesStateService: CategoriesStateService? = nil
    ) {
        self.defaults = defaults
        self.answersService = answersService ?? AnswersService.shared
        self.categoriesStateService = categoriesStateService ?? CategoriesStateService.shared
    }

    @MainActor
    func performReset(
        soundManager: SoundManager,
        languageManager: LanguageManager,
        stateManager: StateManager,
        onboardingPreferences: OnboardingPreferences
    ) {
        clearUserDefaults()
        resetManagers(
            soundManager: soundManager,
            languageManager: languageManager,
            stateManager: stateManager,
            onboardingPreferences: onboardingPreferences
        )
        clearPersistedProgress()
    }

    @MainActor
    private func clearUserDefaults() {
        let criticalKeys: Set<String> = ["settings_initialized", "hasCompletedOnboarding"]
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            guard criticalKeys.contains(key) == false else { return }
            defaults.removeObject(forKey: key)
        }

        defaults.set(true, forKey: "sound_enabled")
        defaults.set(true, forKey: "vibration_enabled")
        defaults.set("system", forKey: "app_appearance")
        defaults.synchronize()
    }

    @MainActor
    private func resetManagers(
        soundManager: SoundManager,
        languageManager: LanguageManager,
        stateManager: StateManager,
        onboardingPreferences: OnboardingPreferences
    ) {
        soundManager.setSoundEnabled(true)
        onboardingPreferences.hasLaunchedBefore = false
        onboardingPreferences.selectedState = nil
        onboardingPreferences.translationSelected = false
        onboardingPreferences.translationLanguageCode = nil
        onboardingPreferences.testDate = nil
        onboardingPreferences.testDateDontKnow = true

        languageManager.setAppLanguage("en")
        languageManager.setTranslationLanguage("de")
        stateManager.clearSelectedState()
    }

    @MainActor
    private func clearPersistedProgress() {
        answersService.clearAllAnswers()
        categoriesStateService.clearAllState()
    }
}

