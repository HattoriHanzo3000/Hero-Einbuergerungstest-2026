import Combine
import Foundation

@MainActor
final class SettingsPersonalisationViewModel: ObservableObject {
    @Published var appearanceMode: AppearanceMode
    @Published var isSoundEnabled: Bool
    @Published var isHapticsEnabled: Bool

    private let soundManager: SoundManager
    private let defaults: UserDefaults
    private var cancellables: Set<AnyCancellable> = []

    private enum Keys {
        static let appearance = "app_appearance"
        static let haptics = "vibration_enabled"
    }

    init(
        soundManager: SoundManager,
        defaults: UserDefaults = .standard
    ) {
        self.soundManager = soundManager
        self.defaults = defaults

        let savedAppearance = defaults.string(forKey: Keys.appearance) ?? AppearanceMode.system.rawValue
        self.appearanceMode = AppearanceMode(from: savedAppearance)
        self.isSoundEnabled = soundManager.isSoundEnabled
        self.isHapticsEnabled = defaults.object(forKey: Keys.haptics) as? Bool ?? true

        observeSoundManager()
    }

    func setAppearance(_ mode: AppearanceMode) {
        guard appearanceMode != mode else { return }
        appearanceMode = mode
        defaults.set(mode.rawValue, forKey: Keys.appearance)
        HapticManager.shared.lightImpact()
    }

    func setSoundEnabled(_ enabled: Bool) {
        guard isSoundEnabled != enabled else { return }
        isSoundEnabled = enabled
        soundManager.setSoundEnabled(enabled)
        HapticManager.shared.lightImpact()
    }

    func setHapticsEnabled(_ enabled: Bool) {
        guard isHapticsEnabled != enabled else { return }
        isHapticsEnabled = enabled
        defaults.set(enabled, forKey: Keys.haptics)
        HapticManager.shared.lightImpact()
    }

    private func observeSoundManager() {
        soundManager.$isSoundEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self else { return }
                if self.isSoundEnabled != newValue {
                    self.isSoundEnabled = newValue
                }
            }
            .store(in: &cancellables)
    }
}

