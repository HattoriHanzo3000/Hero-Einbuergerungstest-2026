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
    
    /// Controls the current top-level navigation stage. Defaults to the main experience.
    @Published var stage: Stage = .main
}
