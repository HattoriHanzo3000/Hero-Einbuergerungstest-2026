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
        resetService: SettingsResetServicing,
        soundManager: SoundManager,
        languageManager: LanguageManager,
        stateManager: StateManager,
        onboardingPreferences: OnboardingPreferences? = nil,
        completion: @escaping @MainActor () -> Void = {}
    ) {
        self.resetService = resetService
        self.soundManager = soundManager
        self.languageManager = languageManager
        self.stateManager = stateManager
        self.onboardingPreferences = onboardingPreferences ?? OnboardingPreferences.shared
        self.completion = completion
    }

    func requestConfirmation() {
        HapticManager.shared.warning()
        isPresentingConfirmation = true
    }

    func cancel() {
        isPresentingConfirmation = false
    }

    func confirm() {
        HapticManager.shared.warning()
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

