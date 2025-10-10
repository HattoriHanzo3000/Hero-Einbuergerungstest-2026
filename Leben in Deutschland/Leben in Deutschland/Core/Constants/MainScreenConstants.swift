import Foundation
import UIKit

// MARK: - Main Screen Constants
struct MainScreenConstants {
    // Layout Ratios (based on old project structure)
    static let headerHeightRatio: CGFloat = 0.24   // 24% of screen height (6% federal state + 18% mascot)
    static let mascotHeightRatio: CGFloat = 0.18   // 18% of screen height  
    static let footerHeightRatio: CGFloat = 0.08   // 8% of screen height
    
    // Header
    static let headerSidePaddingRatio: CGFloat = 0.06  // 6% of screen width
    static let federalStateButtonMaxWidth: CGFloat = 300
    
    // Mascot Section
    static let mascotSidePaddingRatio: CGFloat = 0.05  // 5% of screen width
    static let emojiSizeRatio: CGFloat = 0.28          // 28% of screen width
    static let bubbleWidthRatio: CGFloat = 0.56        // 56% of screen width
    static let mascotBubbleSpacing: CGFloat = 12       // Fixed spacing
    
    // Footer
    static let footerSidePaddingRatio: CGFloat = 0.02  // 2% of screen width
    
    // Categories Grid
    static let categorySpacing: CGFloat = 24
    static let categoryButtonHeight: CGFloat = 72
    static let categoryIconSize: CGFloat = 72
    static let categorySidePadding: CGFloat = 20
    
    // Animation
    static let buttonTapAnimationDuration: Double = 0.22
    static let gifAnimationDuration: Double = 1.1
    
    // Colors
    static let fillColorName = "Fill"  // Primary accent color for the app
}

// MARK: - Screen Dimensions Helper
extension MainScreenConstants {
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
    
    static func getFooterHeight() -> CGFloat {
        return getScreenHeight() * footerHeightRatio
    }
    
    static func getHeaderSidePadding() -> CGFloat {
        return getScreenWidth() * headerSidePaddingRatio
    }
    
    static func getMascotSidePadding() -> CGFloat {
        return getScreenWidth() * mascotSidePaddingRatio
    }
    
    static func getFooterSidePadding() -> CGFloat {
        return getScreenWidth() * footerSidePaddingRatio
    }
    
    static func getEmojiSize() -> CGFloat {
        return getScreenWidth() * emojiSizeRatio
    }
    
    static func getBubbleWidth() -> CGFloat {
        return getScreenWidth() * bubbleWidthRatio
    }
}
