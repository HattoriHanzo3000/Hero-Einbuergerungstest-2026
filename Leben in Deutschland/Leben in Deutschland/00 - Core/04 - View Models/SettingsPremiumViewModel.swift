import Combine
import Foundation

/// Handles Premium upsell interactions in Settings.
@MainActor
final class SettingsPremiumViewModel: ObservableObject {
    func handleTap() {
        SubscriptionManager.shared.presentPaywall()
    }
}

