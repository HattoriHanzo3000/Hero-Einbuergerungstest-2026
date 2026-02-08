//
//  PremiumCrownButton.swift
//  Leben in Deutschland
//
//  Reusable premium crown icon button. Use in headers and anywhere the user
//  can open the paywall (e.g. Superwall). Tappable area meets 44pt minimum.
//

import SwiftUI

// MARK: - Premium Crown Button
/// Filled crown icon that opens premium/paywall. Reusable across the app.
struct PremiumCrownButton: View {
    let action: () -> Void
    
    /// Icon size. Touch target is always at least 44pt.
    var iconSize: CGFloat = 20
    /// Foreground color (e.g. .white on dark headers, .primary on light).
    var color: Color = .white
    
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    private var adaptiveIconSize: CGFloat {
        layoutMetrics.adaptive(iconSize)
    }
    
    private var minTouchSize: CGFloat {
        layoutMetrics.adaptive(44)
    }
    
    var body: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            action()
        }) {
            Image(systemName: "crown.fill")
                .font(.system(size: adaptiveIconSize, weight: .semibold))
                .foregroundColor(color)
                .frame(minWidth: minTouchSize, minHeight: minTouchSize)
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Preview
#Preview("Premium crown (white)") {
    PremiumCrownButton(action: {})
        .padding()
        .background(Color.blue)
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

#Preview("Premium crown (primary)") {
    PremiumCrownButton(action: {}, color: .primary)
        .padding()
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
