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
    static let headerHeightRatio: CGFloat = 0.05  // 5% of screen height
    static let mascotHeightRatio: CGFloat = 0.23   // 23% of screen height
    static let sidePaddingRatio: CGFloat = 0.05    // 5% of screen width
    static let emojiSizeRatio: CGFloat = 0.28      // 28% of screen width
    static let bubbleWidthRatio: CGFloat = 0.6     // 60% of screen width
    static let buttonWidthRatio: CGFloat = 0.9    // 90% of screen width
    
    // Animation
    static let dialogDelay: Double = 0.3
    static let animationDuration: Double = 0.5
    static let gifAnimationDuration: Double = 1.1
    
    // Spacing
    static let defaultSpacing: CGFloat = 12
    static let buttonSpacing: CGFloat = 15
    static let padding: CGFloat = 20
}

// MARK: - Screen Dimensions Helper
extension OnboardingConstants {
    static func getScreenWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static func getScreenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    static func getHeaderHeight() -> CGFloat {
        return getScreenHeight() * headerHeightRatio
    }
    
    static func getMascotHeight() -> CGFloat {
        return getScreenHeight() * mascotHeightRatio
    }
    
    static func getSidePadding() -> CGFloat {
        return getScreenWidth() * sidePaddingRatio
    }
    
    static func getEmojiSize() -> CGFloat {
        return getScreenWidth() * emojiSizeRatio
    }
    
    static func getBubbleWidth() -> CGFloat {
        return getScreenWidth() * bubbleWidthRatio
    }
    
    static func getButtonWidth() -> CGFloat {
        return getScreenWidth() * buttonWidthRatio
    }
}
