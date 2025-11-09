import Foundation
import UIKit

// MARK: - Onboarding Constants
struct OnboardingConstants {
    // Progress
    static let totalSteps = 4
    static let languageStep = 1
    static let translationStep = 2
    static let stateStep = 3
    static let dateStep = 4
    
    // Layout Ratios
    static let buttonWidthRatio: CGFloat = 0.9    // 90% of screen width
    
    // Animation
    static let dialogDelay: Double = 0.3
    static let gifAnimationDuration: Double = 1.1
    static let videoCompletionDelay: Double = 0.5
    static let videoFallbackDelay: Double = 6.0
    static let videoNotFoundDelay: Double = 1.0
    static let onboardingCompleteDelay: Double = 0.3
    
    // Spacing
    static let defaultSpacing: CGFloat = 12
    static let headerTopPadding: CGFloat = 4
    static let contentVerticalPadding: CGFloat = 6
    static let containerSectionSpacing: CGFloat = 8
    static let progressBarHorizontalPadding: CGFloat = 30
}

// MARK: - Screen Dimensions Helper
extension OnboardingConstants {
    static func getScreenWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static func getScreenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    static func getButtonWidth() -> CGFloat {
        return getScreenWidth() * buttonWidthRatio
    }
}
