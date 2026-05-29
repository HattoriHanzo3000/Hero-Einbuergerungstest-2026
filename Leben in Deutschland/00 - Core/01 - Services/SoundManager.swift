import AVFoundation
import Combine
import Foundation

// MARK: - Sound Manager
final class SoundManager: ObservableObject {
    static let shared = SoundManager()

    @Published private(set) var isSoundEnabled: Bool {
        didSet {
            defaults.set(isSoundEnabled, forKey: Self.preferenceKey)
        }
    }

    private let defaults: UserDefaults
    private static let preferenceKey = UserDefaultsKeys.soundEnabled

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if defaults.object(forKey: Self.preferenceKey) == nil {
            defaults.set(true, forKey: Self.preferenceKey)
        }

        self.isSoundEnabled = defaults.object(forKey: Self.preferenceKey) as? Bool ?? true
    }

    // MARK: - Public API
    func setSoundEnabled(_ enabled: Bool) {
        guard enabled != isSoundEnabled else { return }
        isSoundEnabled = enabled
    }

    func toggleSound() {
        setSoundEnabled(!isSoundEnabled)
    }
}
