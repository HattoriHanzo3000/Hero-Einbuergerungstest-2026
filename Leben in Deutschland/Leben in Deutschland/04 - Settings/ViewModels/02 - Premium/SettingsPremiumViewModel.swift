import Combine
import Foundation

/// Handles Premium upsell interactions in Settings.
@MainActor
final class SettingsPremiumViewModel: ObservableObject {
    let onPresentPremium: () -> Void

    init(onPresentPremium: @escaping () -> Void = {}) {
        self.onPresentPremium = onPresentPremium
    }

    func handleTap() {
        HapticManager.shared.lightImpact()
        onPresentPremium()
    }
}

