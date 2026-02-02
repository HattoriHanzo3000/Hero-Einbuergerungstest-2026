import Foundation

/// Represents version metadata displayed in the Settings dashboard.
struct SettingsVersionInfoModel: Equatable {
    let currentVersion: String
    let latestAvailableVersion: String
}

