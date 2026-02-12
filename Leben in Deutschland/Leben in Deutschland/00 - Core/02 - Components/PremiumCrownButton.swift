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
/// Scales with Dynamic Type to match AdaptiveIconButton (back, search).
struct PremiumCrownButton: View {
    let action: () -> Void
    
    /// Foreground color (e.g. .white on dark headers, .primary on light).
    var color: Color = .white
    
    @Environment(\.layoutMetrics) private var layoutMetrics
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    private var controlSize: CGFloat {
        layoutMetrics.adaptive(baseControlSize(for: dynamicTypeSize))
    }
    
    /// Matches AdaptiveIconButton.standard sizing for Dynamic Type.
    private func baseControlSize(for dynamicType: DynamicTypeSize) -> CGFloat {
        switch dynamicType {
        case .xSmall, .small, .medium:
            return 36
        case .large:
            return 38
        case .xLarge:
            return 40
        default:
            return 44
        }
    }
    
    var body: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            action()
        }) {
            Image(systemName: "crown.fill")
                .font(.system(.body, design: .rounded).weight(.semibold))
                .foregroundColor(color)
                .frame(width: controlSize, height: controlSize)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
