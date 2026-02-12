import Foundation

final class OnboardingPreferences {
    static let shared = OnboardingPreferences()
    private let defaults: UserDefaults
    
    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    private enum Keys {
        static let hasLaunchedBefore = "hasLaunchedBefore"
        static let selectedState = UserDefaultsKeys.selectedState
        static let translationSelected = "translationSelected"
        static let translationLanguageCode = "translationLanguageCode"
        static let testDateDontKnow = "testDateDontKnow"
        static let testDate = "testDate"
    }
    
    var hasLaunchedBefore: Bool {
        get { defaults.bool(forKey: Keys.hasLaunchedBefore) }
        set { defaults.set(newValue, forKey: Keys.hasLaunchedBefore) }
    }
    
    func clearSelectedState() {
        defaults.removeObject(forKey: Keys.selectedState)
    }
    
    /// Clears onboarding selections when starting a fresh onboarding run.
    /// Call when transitioning from start animation to onboarding language.
    func clearOnboardingSelections() {
        defaults.removeObject(forKey: Keys.selectedState)
        defaults.removeObject(forKey: Keys.testDate)
        defaults.set(false, forKey: Keys.testDateDontKnow)
        defaults.set(false, forKey: Keys.translationSelected)
        defaults.removeObject(forKey: Keys.translationLanguageCode)
    }

    var selectedState: String? {
        get { defaults.string(forKey: Keys.selectedState) }
        set { defaults.set(newValue, forKey: Keys.selectedState) }
    }

    var translationSelected: Bool {
        get { defaults.bool(forKey: Keys.translationSelected) }
        set { defaults.set(newValue, forKey: Keys.translationSelected) }
    }

    var translationLanguageCode: String? {
        get { defaults.string(forKey: Keys.translationLanguageCode) }
        set { defaults.set(newValue, forKey: Keys.translationLanguageCode) }
    }

    var testDateDontKnow: Bool {
        get { defaults.bool(forKey: Keys.testDateDontKnow) }
        set { defaults.set(newValue, forKey: Keys.testDateDontKnow) }
    }

    var testDate: Date? {
        get {
            let time = defaults.double(forKey: Keys.testDate)
            return time == 0 ? nil : Date(timeIntervalSince1970: time)
        }
        set {
            if let date = newValue {
                defaults.set(date.timeIntervalSince1970, forKey: Keys.testDate)
                testDateDontKnow = false
            } else {
                defaults.removeObject(forKey: Keys.testDate)
            }
        }
    }
}
