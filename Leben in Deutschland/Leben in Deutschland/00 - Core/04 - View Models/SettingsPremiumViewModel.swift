import Combine
import Foundation

/// Handles Pro upsell interactions in Settings.
@MainActor
final class SettingsProViewModel: ObservableObject {
    func handleTap() {
        SubscriptionManager.shared.presentPaywall()
    }
}

typealias SettingsPremiumViewModel = SettingsProViewModel

