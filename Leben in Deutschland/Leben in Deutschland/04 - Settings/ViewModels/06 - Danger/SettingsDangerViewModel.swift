import Combine
import Foundation

@MainActor
final class SettingsDangerViewModel: ObservableObject {
    @Published var isPresentingConfirmation: Bool = false
    private let resetService: SettingsResetServicing
    private let soundManager: SoundManager
    private let languageManager: LanguageManager
    private let stateManager: StateManager
    private let onboardingPreferences: OnboardingPreferences
    private let completion: @MainActor () -> Void

    init(
        resetService: SettingsResetServicing = SettingsResetService.shared,
        soundManager: SoundManager,
        languageManager: LanguageManager,
        stateManager: StateManager,
        onboardingPreferences: OnboardingPreferences = .shared,
        completion: @escaping @MainActor () -> Void = {}
    ) {
        self.resetService = resetService
        self.soundManager = soundManager
        self.languageManager = languageManager
        self.stateManager = stateManager
        self.onboardingPreferences = onboardingPreferences
        self.completion = completion
    }

    func requestConfirmation() {
        HapticManager.shared.heavyImpact()
        isPresentingConfirmation = true
    }

    func cancel() {
        HapticManager.shared.lightImpact()
        isPresentingConfirmation = false
    }

    func confirm() {
        HapticManager.shared.heavyImpact()
        isPresentingConfirmation = false
        resetService.performReset(
            soundManager: soundManager,
            languageManager: languageManager,
            stateManager: stateManager,
            onboardingPreferences: onboardingPreferences
        )
        completion()
    }
}

