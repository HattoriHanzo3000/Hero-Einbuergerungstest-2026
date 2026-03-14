// AppFlow.swift (new file)
import Foundation
import Combine

final class AppFlow: ObservableObject {
    enum Stage {
        case startAnimation
        case onboardingLanguage
        case onboardingTranslation
        case onboardingState
        case onboardingDate
        case onboardingPaywall
        case onboardingSplash
        case main
    }
    
    /// Controls the current top-level navigation stage. Shows onboarding on first launch.
    @Published var stage: Stage

    init() {
        _stage = Published(
            initialValue: UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") ? .main : .startAnimation
        )
    }
}
