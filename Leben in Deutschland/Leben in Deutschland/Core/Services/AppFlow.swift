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
        case onboardingSplash
        case main
    }
    
    @Published var stage: Stage = {
        #if DEBUG
        return .main  // Skip onboarding in development builds
        #else
        return .startAnimation
        #endif
    }()
}
