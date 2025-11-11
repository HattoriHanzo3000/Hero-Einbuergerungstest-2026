import Combine
import Foundation
import os.log

/// Handles version-related actions for the Settings dashboard.
@MainActor
final class SettingsVersionViewModel: ObservableObject {
    @Published private(set) var versionInfo: SettingsVersionInfoModel

    var latestVersion: String {
        versionInfo.latestAvailableVersion
    }

    var latestVersionIsNewer: Bool {
        compareVersions(versionInfo.currentVersion, versionInfo.latestAvailableVersion) == .orderedAscending
    }

    private let appStoreURL: URL?
    private let latestVersionProvider: () -> String
    private let logger = Logger(subsystem: "SettingsVersionViewModel", category: "Settings")

    init(
        currentVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
        latestVersionProvider: @escaping () -> String = { "1.1.5" },
        appStoreURL: URL? = URL(string: "https://apps.apple.com/de/app/hero-leben-in-deutschland/id6752272685")
    ) {
        self.versionInfo = SettingsVersionInfoModel(
            currentVersion: currentVersion,
            latestAvailableVersion: latestVersionProvider()
        )
        self.latestVersionProvider = latestVersionProvider
        self.appStoreURL = appStoreURL
    }

    func refreshVersionInfo() {
        versionInfo = SettingsVersionInfoModel(
            currentVersion: versionInfo.currentVersion,
            latestAvailableVersion: latestVersionProvider()
        )
    }

    func appStoreDestination() -> URL? {
        appStoreURL
    }

    private func compareVersions(_ lhs: String, _ rhs: String) -> ComparisonResult {
        let lhsComponents = lhs.split(separator: ".").map { Int($0) ?? 0 }
        let rhsComponents = rhs.split(separator: ".").map { Int($0) ?? 0 }
        let maxCount = max(lhsComponents.count, rhsComponents.count)

        for index in 0..<maxCount {
            let left = index < lhsComponents.count ? lhsComponents[index] : 0
            let right = index < rhsComponents.count ? rhsComponents[index] : 0
            if left < right { return .orderedAscending }
            if left > right { return .orderedDescending }
        }

        return .orderedSame
    }
}

