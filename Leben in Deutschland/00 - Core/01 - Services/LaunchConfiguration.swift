//
//  LaunchConfiguration.swift
//  Leben in Deutschland
//
//  DEBUG-only launch profiles driven by the LID_LAUNCH_PROFILE scheme environment variable.
//  Created: 27.06.26.
//

#if DEBUG
import Foundation

// MARK: - Launch Configuration

/// Seeds UserDefaults and debug overrides before AppFlow / LanguageManager initialize.
enum LaunchConfiguration {
    static let environmentKey = "LID_LAUNCH_PROFILE"

    /// Federal state to apply after SwiftData attaches (set by launch profiles that change state).
    private(set) static var pendingFederalStateReload: String?

    static func applyIfNeeded() {
        guard let rawProfile = ProcessInfo.processInfo.environment[environmentKey],
              !rawProfile.isEmpty,
              let kind = parseProfile(rawProfile)
        else {
            return
        }

        apply(kind)
    }

    /// Returns and clears a deferred federal-state reload requested at launch.
    static func consumePendingFederalStateReload() -> String? {
        defer { pendingFederalStateReload = nil }
        return pendingFederalStateReload
    }

    // MARK: - Private

    private enum ProfileKind {
        case standard(LaunchProfile)
        case launchOffer(appLanguageCode: String)
        case paywallLimits(appLanguageCode: String)
    }

    private static let supportedAppLanguageCodes: Set<String> = ["de", "en", "ru", "tr", "uk"]

    private static func parseProfile(_ raw: String) -> ProfileKind? {
        if let profile = LaunchProfile(rawValue: raw) {
            return .standard(profile)
        }
        if raw.hasPrefix("launch_offer_") {
            let code = String(raw.dropFirst("launch_offer_".count))
            guard supportedAppLanguageCodes.contains(code) else { return nil }
            return .launchOffer(appLanguageCode: code)
        }
        if raw.hasPrefix("paywall_limits_") {
            let code = String(raw.dropFirst("paywall_limits_".count))
            guard supportedAppLanguageCodes.contains(code) else { return nil }
            return .paywallLimits(appLanguageCode: code)
        }
        return nil
    }

    private static func apply(_ kind: ProfileKind) {
        switch kind {
        case .standard(.onboardingFresh):
            resetForFreshOnboarding()
            DebugOverrides.shared.simulatePro = nil
        case .standard(let profile):
            let settings = profile.resolvedSettings
            seedCompletedAppPreferences(settings)
            applyProSimulation(settings.simulatePro)
        case .launchOffer(let appLanguageCode):
            let pair = languagePair(forAppLanguage: appLanguageCode)
            seedCompletedAppPreferences(
                LaunchProfileSettings(
                    appLanguage: pair.app,
                    translationLanguage: pair.translation,
                    federalState: "Berlin",
                    simulatePro: false
                )
            )
            applyProSimulation(false)
            applyActiveLaunchOffer()
        case .paywallLimits(let appLanguageCode):
            let pair = languagePair(forAppLanguage: appLanguageCode)
            seedCompletedAppPreferences(
                LaunchProfileSettings(
                    appLanguage: pair.app,
                    translationLanguage: pair.translation,
                    federalState: "Berlin",
                    simulatePro: false
                )
            )
            applyProSimulation(false)
            applyExpiredLaunchOfferWithPaywallLimits()
        }
    }

    private static func languagePair(forAppLanguage appCode: String) -> (app: String, translation: String) {
        if appCode == "de" {
            return ("de", "ru")
        }
        return (appCode, "de")
    }

    private static func resetForFreshOnboarding() {
        let defaults = UserDefaults.standard
        let onboarding = OnboardingPreferences.shared

        defaults.set(false, forKey: "hasCompletedOnboarding")
        onboarding.hasLaunchedBefore = false
        onboarding.clearOnboardingSelections()
        onboarding.testDateDontKnow = true

        defaults.removeObject(forKey: "appLanguage")
        defaults.removeObject(forKey: "translationLanguage")
        defaults.removeObject(forKey: UserDefaultsKeys.selectedState)
        defaults.removeObject(forKey: UserDefaultsKeys.selectedTestDate)
        defaults.removeObject(forKey: UserDefaultsKeys.debugSimulatePro)
        defaults.removeObject(forKey: UserDefaultsKeys.debugReadinessPercent)

        StateManager.shared.clearSelectedState()
        DebugOverrides.shared.clearAll()
    }

    private static func seedCompletedAppPreferences(_ settings: LaunchProfileSettings) {
        let defaults = UserDefaults.standard
        let onboarding = OnboardingPreferences.shared

        defaults.set(true, forKey: "hasCompletedOnboarding")
        defaults.set(settings.appLanguage, forKey: "appLanguage")
        defaults.set(settings.translationLanguage, forKey: "translationLanguage")
        defaults.set(settings.federalState, forKey: UserDefaultsKeys.selectedState)

        onboarding.hasLaunchedBefore = true
        onboarding.selectedState = settings.federalState
        onboarding.translationSelected = true
        onboarding.translationLanguageCode = settings.translationLanguage

        StateManager.shared.setSelectedState(settings.federalState)
        pendingFederalStateReload = settings.federalState
    }

    private static func applyProSimulation(_ simulatePro: Bool?) {
        DebugOverrides.shared.simulatePro = simulatePro
    }

    private static func applyActiveLaunchOffer() {
        let defaults = UserDefaults.standard
        defaults.set(Date(), forKey: UserDefaultsKeys.firstLaunchDate)
        defaults.set(false, forKey: UserDefaultsKeys.lastKnownPremiumState)
    }

    private static func applyExpiredLaunchOfferWithPaywallLimits() {
        let defaults = UserDefaults.standard
        let expiredLaunch = Date().addingTimeInterval(-4 * 24 * 60 * 60)
        defaults.set(expiredLaunch, forKey: UserDefaultsKeys.firstLaunchDate)
        defaults.set(false, forKey: UserDefaultsKeys.lastKnownPremiumState)
        defaults.set(
            FreemiumLimits.freeSmartLearningQuestions,
            forKey: UserDefaultsKeys.freemiumSmartLearningAnswerCount
        )
        defaults.set(
            FreemiumLimits.freeTestSimulations,
            forKey: UserDefaultsKeys.freemiumTestSimulationsStartedCount
        )
    }
}

// MARK: - Launch Profile

private enum LaunchProfile: String {
    case `default` = "default"
    case langEN = "lang_en"
    case langRU = "lang_ru"
    case langTR = "lang_tr"
    case langUK = "lang_uk"
    case onboardingFresh = "onboarding_fresh"

    // Federal states — prefix state_
    case stateBadenWuerttemberg = "state_baden_wuerttemberg"
    case stateBayern = "state_bayern"
    case stateBerlin = "state_berlin"
    case stateBrandenburg = "state_brandenburg"
    case stateBremen = "state_bremen"
    case stateHamburg = "state_hamburg"
    case stateHessen = "state_hessen"
    case stateMecklenburgVorpommern = "state_mecklenburg_vorpommern"
    case stateNiedersachsen = "state_niedersachsen"
    case stateNordrheinWestfalen = "state_nordrhein_westfalen"
    case stateRheinlandPfalz = "state_rheinland_pfalz"
    case stateSaarland = "state_saarland"
    case stateSachsen = "state_sachsen"
    case stateSachsenAnhalt = "state_sachsen_anhalt"
    case stateSchleswigHolstein = "state_schleswig_holstein"
    case stateThueringen = "state_thueringen"

    var resolvedSettings: LaunchProfileSettings {
        switch self {
        case .default:
            return LaunchProfileSettings(
                appLanguage: "de",
                translationLanguage: "ru",
                federalState: "Berlin",
                simulatePro: true
            )
        case .langEN:
            return LaunchProfileSettings(
                appLanguage: "en",
                translationLanguage: "de",
                federalState: "Berlin",
                simulatePro: true
            )
        case .langRU:
            return LaunchProfileSettings(
                appLanguage: "ru",
                translationLanguage: "de",
                federalState: "Berlin",
                simulatePro: true
            )
        case .langTR:
            return LaunchProfileSettings(
                appLanguage: "tr",
                translationLanguage: "de",
                federalState: "Berlin",
                simulatePro: true
            )
        case .langUK:
            return LaunchProfileSettings(
                appLanguage: "uk",
                translationLanguage: "de",
                federalState: "Berlin",
                simulatePro: true
            )
        case .stateBadenWuerttemberg:
            return stateSettings(named: "Baden-Württemberg")
        case .stateBayern:
            return stateSettings(named: "Bayern")
        case .stateBerlin:
            return stateSettings(named: "Berlin")
        case .stateBrandenburg:
            return stateSettings(named: "Brandenburg")
        case .stateBremen:
            return stateSettings(named: "Bremen")
        case .stateHamburg:
            return stateSettings(named: "Hamburg")
        case .stateHessen:
            return stateSettings(named: "Hessen")
        case .stateMecklenburgVorpommern:
            return stateSettings(named: "Mecklenburg-Vorpommern")
        case .stateNiedersachsen:
            return stateSettings(named: "Niedersachsen")
        case .stateNordrheinWestfalen:
            return stateSettings(named: "Nordrhein-Westfalen")
        case .stateRheinlandPfalz:
            return stateSettings(named: "Rheinland-Pfalz")
        case .stateSaarland:
            return stateSettings(named: "Saarland")
        case .stateSachsen:
            return stateSettings(named: "Sachsen")
        case .stateSachsenAnhalt:
            return stateSettings(named: "Sachsen-Anhalt")
        case .stateSchleswigHolstein:
            return stateSettings(named: "Schleswig-Holstein")
        case .stateThueringen:
            return stateSettings(named: "Thüringen")
        case .onboardingFresh:
            fatalError("onboarding_fresh does not use resolvedSettings")
        }
    }

    private func stateSettings(named federalState: String) -> LaunchProfileSettings {
        LaunchProfileSettings(
            appLanguage: "de",
            translationLanguage: "ru",
            federalState: federalState,
            simulatePro: true
        )
    }
}

// MARK: - Launch Profile Settings

private struct LaunchProfileSettings {
    let appLanguage: String
    let translationLanguage: String
    let federalState: String
    let simulatePro: Bool?
}
#endif
