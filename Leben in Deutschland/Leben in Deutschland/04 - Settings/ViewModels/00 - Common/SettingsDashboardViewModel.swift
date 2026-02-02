import Combine
import SwiftUI

/// Coordinates data and actions for `SettingsDashboardView`.
@MainActor
final class SettingsDashboardViewModel: ObservableObject {
    // Temporary placeholder publishers for upcoming sections.
    @Published var isLoading: Bool = false
    let versionViewModel: SettingsVersionViewModel
    let premiumViewModel: SettingsPremiumViewModel
    let supportViewModel: SettingsSupportViewModel
    let legalViewModel: SettingsLegalViewModel
    @Published private(set) var regionalViewModel: SettingsRegionalViewModel?
    @Published private(set) var personalisationViewModel: SettingsPersonalisationViewModel?
    @Published private(set) var dangerViewModel: SettingsDangerViewModel?
    @Published var navigationPath: [SettingsDashboardRoute] = []

    private var cancellables: Set<AnyCancellable> = []

    init(
        versionViewModel: SettingsVersionViewModel? = nil,
        premiumViewModel: SettingsPremiumViewModel? = nil,
        supportViewModel: SettingsSupportViewModel? = nil,
        legalViewModel: SettingsLegalViewModel? = nil,
        regionalViewModel: SettingsRegionalViewModel? = nil,
        personalisationViewModel: SettingsPersonalisationViewModel? = nil
    ) {
        self.versionViewModel = versionViewModel ?? SettingsVersionViewModel()
        self.premiumViewModel = premiumViewModel ?? SettingsPremiumViewModel()
        self.supportViewModel = supportViewModel ?? SettingsSupportViewModel()
        self.legalViewModel = legalViewModel ?? SettingsLegalViewModel()
        self.regionalViewModel = regionalViewModel
        self.personalisationViewModel = personalisationViewModel
        // Step 3 will attach services and bindings here.
    }

    func configureRegionalSection(
        languageManager: LanguageManager,
        stateManager: StateManager,
        onboardingPreferences: OnboardingPreferences? = nil
    ) {
        guard regionalViewModel == nil else { return }
        let resolvedPreferences = onboardingPreferences ?? OnboardingPreferences.shared
        regionalViewModel = SettingsRegionalViewModel(
            languageManager: languageManager,
            stateManager: stateManager,
            onboardingPreferences: resolvedPreferences
        )
    }

    func configurePersonalisationSection(
        soundManager: SoundManager,
        defaults: UserDefaults = .standard
    ) {
        guard personalisationViewModel == nil else { return }
        personalisationViewModel = SettingsPersonalisationViewModel(
            soundManager: soundManager,
            defaults: defaults
        )
    }

    func configureDangerSection(
        soundManager: SoundManager,
        languageManager: LanguageManager,
        stateManager: StateManager,
        onboardingPreferences: OnboardingPreferences? = nil,
        resetCompletion: @escaping @MainActor () -> Void = {}
    ) {
        guard dangerViewModel == nil else { return }
        let resolvedPreferences = onboardingPreferences ?? OnboardingPreferences.shared
        dangerViewModel = SettingsDangerViewModel(
            resetService: SettingsResetService.shared,
            soundManager: soundManager,
            languageManager: languageManager,
            stateManager: stateManager,
            onboardingPreferences: resolvedPreferences,
            completion: resetCompletion
        )
    }
}

