import SwiftUI

/// Shared design tokens for the Settings feature.
enum SettingsDesignTokens {
    enum Palette {
        static let updates = SwiftUI.Color.accentColor
        static let premium = SwiftUI.Color(red: 0.96, green: 0.78, blue: 0.24)
        static let regional = SwiftUI.Color(uiColor: .systemPurple)
        static let personalisation = SwiftUI.Color(uiColor: .systemGreen)
        static let support = SwiftUI.Color(uiColor: .systemOrange)
        static let legal = SwiftUI.Color(red: 0.16, green: 0.28, blue: 0.47)
        static let danger = SwiftUI.Color(uiColor: .systemRed)
        static let trailingValue = SwiftUI.Color.secondary
        static let notification = SwiftUI.Color(uiColor: .systemRed)
    }

    enum Layout {
        /// Horizontal spacing between icon, title, and trailing controls in a row.
        /// Slightly tighter to better match native Settings rows.
        static let rowSpacing: CGFloat = 8
        static let sectionSpacing: CGFloat = 20
        static let cornerRadius: CGFloat = 12
        static let iconCornerRadius: CGFloat = 8
        static let iconStrokeWidth: CGFloat = 0.6
        /// Extra vertical padding inside custom HStack rows (most vertical sizing comes from List itself).
        /// Set to 0 to keep rows visually closer to system defaults.
        static let rowVerticalPadding: CGFloat = 0
    }

    enum Icon {
        static let containerSize: CGFloat = 32
        static let symbolSize: CGFloat = 16
        static let trailingChevronSize: CGFloat = 14
        static let trailingChevronWeight: Font.Weight = .semibold
        static let badgeSize: CGFloat = 10
    }
}

