import Foundation

final class OnboardingPreferences {
    static let shared = OnboardingPreferences()
    private let defaults: UserDefaults
    
    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    private enum Keys {
        static let hasLaunchedBefore = "hasLaunchedBefore"
        static let selectedState = "selectedState"
        static let translationSelected = "translationSelected"
        static let translationLanguageCode = "translationLanguageCode"
        static let testDateDontKnow = "testDateDontKnow"
    }
    
    var hasLaunchedBefore: Bool {
        get { defaults.bool(forKey: Keys.hasLaunchedBefore) }
        set { defaults.set(newValue, forKey: Keys.hasLaunchedBefore) }
    }
    
    func clearSelectedState() {
        defaults.removeObject(forKey: Keys.selectedState)
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
}
