//
//  UserDefaultsKeys.swift
//  Leben in Deutschland
//
//  Shared keys for UserDefaults to avoid drift between StateManager and OnboardingPreferences.
//

import Foundation

enum UserDefaultsKeys {
    static let selectedState = "selectedState"
    static let vibrationEnabled = "vibration_enabled"
    static let soundEnabled = "sound_enabled"
    static let appearance = "app_appearance"
}
