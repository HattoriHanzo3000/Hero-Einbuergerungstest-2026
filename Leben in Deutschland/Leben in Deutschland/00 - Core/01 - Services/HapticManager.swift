//
//  HapticManager.swift
//  Leben in Deutschland
//
//  Centralized haptic feedback using Apple's native UIFeedbackGenerator APIs.
//  Uses shared generators with prepare() for low-latency response per HIG.
//

import Foundation
import UIKit

// MARK: - Haptic Manager
@MainActor
final class HapticManager {
    static let shared = HapticManager()
    
    // MARK: - Shared Generators (reused for performance, prepared before each use)
    private let lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    private init() {}
    
    // MARK: - Settings
    private var isVibrationEnabled: Bool {
        UserDefaults.standard.object(forKey: UserDefaultsKeys.vibrationEnabled) as? Bool ?? true
    }
    
    // MARK: - Haptic Feedback Methods
    
    /// Light haptic for regular button taps, toggles, navigation
    func lightImpact() {
        guard isVibrationEnabled else { return }
        lightImpactGenerator.prepare()
        lightImpactGenerator.impactOccurred()
    }
    
    /// Medium haptic for important actions (e.g. Next, primary confirm)
    func mediumImpact() {
        guard isVibrationEnabled else { return }
        mediumImpactGenerator.prepare()
        mediumImpactGenerator.impactOccurred()
    }
    
    /// Heavy haptic for critical actions (e.g. destructive confirm)
    func heavyImpact() {
        guard isVibrationEnabled else { return }
        heavyImpactGenerator.prepare()
        heavyImpactGenerator.impactOccurred()
    }
    
    /// Selection haptic for picker changes, tab bar, segmented control (Apple native pattern)
    func selectionChanged() {
        guard isVibrationEnabled else { return }
        selectionGenerator.prepare()
        selectionGenerator.selectionChanged()
    }
    
    /// Success haptic for correct answers, completion
    func success() {
        guard isVibrationEnabled else { return }
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(.success)
    }
    
    /// Error haptic for wrong answers, errors
    func error() {
        guard isVibrationEnabled else { return }
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(.error)
    }
    
    /// Strong error haptic for wrong answers (error + heavy impact)
    func errorStrong() {
        guard isVibrationEnabled else { return }
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(.error)
        heavyImpactGenerator.prepare()
        heavyImpactGenerator.impactOccurred()
    }
    
    /// Warning haptic for important warnings
    func warning() {
        guard isVibrationEnabled else { return }
        notificationGenerator.prepare()
        notificationGenerator.notificationOccurred(.warning)
    }
}
