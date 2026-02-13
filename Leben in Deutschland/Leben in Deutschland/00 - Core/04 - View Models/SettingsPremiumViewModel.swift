import Combine
import Foundation

/// Handles Premium upsell interactions in Settings.
@MainActor
final class SettingsPremiumViewModel: ObservableObject {
    func handleTap() {
        PremiumManager.shared.presentPaywall()
    }
}

