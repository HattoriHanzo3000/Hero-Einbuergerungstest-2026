import Foundation
import UIKit

// MARK: - Main Screen Constants
struct MainScreenConstants {
    // Categories Grid
    static var categorySpacing: CGFloat { adaptiveValue(24) }
    static var categoryButtonHeight: CGFloat { adaptiveValue(70) }
    static var categoryIconSize: CGFloat { adaptiveValue(66) }
    static let categorySidePadding: CGFloat = 20
    
    // Animation
    static let buttonTapAnimationDuration: Double = 0.22
    static let gifAnimationDuration: Double = 1.1
    
    // Colors
    static let fillColorName = "Fill"  // Primary accent color for the app
}

// MARK: - Screen Dimensions Helper
extension MainScreenConstants {
    private static let referenceScreenHeight: CGFloat = 844 // Base on iPhone 14/15
    private static let minimumScale: CGFloat = 0.82
    
    static func scaleFactor(for screenHeight: CGFloat = UIScreen.main.bounds.height) -> CGFloat {
        let factor = screenHeight / referenceScreenHeight
        return min(1.0, max(minimumScale, factor))
    }
    
    static func adaptiveValue(_ base: CGFloat) -> CGFloat {
        base * scaleFactor()
    }
    
    static func getScreenWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static func getScreenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
}
