import Foundation
import UIKit

// MARK: - Haptic Manager
@MainActor
class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // MARK: - Settings
    private var isVibrationEnabled: Bool {
        return UserDefaults.standard.object(forKey: "vibration_enabled") as? Bool ?? true
    }
    
    // MARK: - Haptic Feedback Methods
    
    /// Light haptic for regular button taps
    func lightImpact() {
        guard isVibrationEnabled else { return }
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    /// Medium haptic for important actions
    func mediumImpact() {
        guard isVibrationEnabled else { return }
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    /// Heavy haptic for critical actions
    func heavyImpact() {
        guard isVibrationEnabled else { return }
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    /// Success haptic for correct answers, completion
    func success() {
        guard isVibrationEnabled else { return }
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    /// Error haptic for wrong answers, errors
    func error() {
        guard isVibrationEnabled else { return }
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
    
    /// Warning haptic for important warnings
    func warning() {
        guard isVibrationEnabled else { return }
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
}
