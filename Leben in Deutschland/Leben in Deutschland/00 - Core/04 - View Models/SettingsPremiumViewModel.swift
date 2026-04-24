import Combine
import Foundation

/// Handles Pro upsell interactions in Settings.
@MainActor
final class SettingsProViewModel: ObservableObject {
    private var onTap: () -> Void

    init(onTap: (() -> Void)? = nil) {
        self.onTap = onTap ?? {
            SubscriptionManager.shared.presentPaywall()
        }
    }

    func setTapHandler(_ handler: @escaping () -> Void) {
        onTap = handler
    }

    func handleTap() {
        onTap()
    }
}

typealias SettingsPremiumViewModel = SettingsProViewModel

