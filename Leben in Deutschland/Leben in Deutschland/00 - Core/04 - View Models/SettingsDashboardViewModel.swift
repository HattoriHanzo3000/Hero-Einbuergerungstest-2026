import Combine
import SwiftUI

/// Coordinates data and actions for `SettingsDashboardView`.
@MainActor
final class SettingsDashboardViewModel: ObservableObject {
    let premiumViewModel: SettingsPremiumViewModel
    let supportViewModel: SettingsSupportViewModel
    let legalViewModel: SettingsLegalViewModel
    @Published private(set) var regionalViewModel: SettingsRegionalViewModel?
    @Published private(set) var personalisationViewModel: SettingsPersonalisationViewModel?
    @Published private(set) var dangerViewModel: SettingsDangerViewModel?
    @Published var navigationPath: [SettingsDashboardRoute] = []

    private var cancellables: Set<AnyCancellable> = []

    init(
        premiumViewModel: SettingsPremiumViewModel? = nil,
        supportViewModel: SettingsSupportViewModel? = nil,
        legalViewModel: SettingsLegalViewModel? = nil,
        regionalViewModel: SettingsRegionalViewModel? = nil,
        personalisationViewModel: SettingsPersonalisationViewModel? = nil
    ) {
        self.premiumViewModel = premiumViewModel ?? SettingsPremiumViewModel()
        self.supportViewModel = supportViewModel ?? SettingsSupportViewModel()
        self.legalViewModel = legalViewModel ?? SettingsLegalViewModel()
        self.regionalViewModel = regionalViewModel
        self.personalisationViewModel = personalisationViewModel

        regionalViewModel?.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        // Forward supportViewModel changes so SettingsDashboardView re-renders when FAQ/mail state changes
        self.supportViewModel.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)

        // Forward legalViewModel changes so SettingsDashboardView re-renders when Impressum/Terms/Privacy sheet state changes
        self.legalViewModel.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }

    func configureRegionalSection(
        languageManager: LanguageManager,
        stateManager: StateManager,
        onboardingPreferences: OnboardingPreferences? = nil
    ) {
        guard regionalViewModel == nil else { return }
        let resolvedPreferences = onboardingPreferences ?? OnboardingPreferences.shared
        let vm = SettingsRegionalViewModel(
            languageManager: languageManager,
            stateManager: stateManager,
            onboardingPreferences: resolvedPreferences
        )
        regionalViewModel = vm
        vm.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
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

