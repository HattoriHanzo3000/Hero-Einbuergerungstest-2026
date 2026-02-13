//
//  HeaderCard.swift
//  Leben in Deutschland
//
//  Shared card container for headers. Applies liquid glass background, border, shadow.
//  Used by ScreenHeaderCard and others. Header = fixed section; HeaderCard = rounded card inside.
//

import SwiftUI

// MARK: - Header Card
struct HeaderCard<Content: View>: View {
    @Environment(\.layoutMetrics) private var layoutMetrics

    var gradient: LiquidGlassGradient = .blue
    var showPremiumButton: Bool = false
    var onPremiumTap: (() -> Void)?
    @ViewBuilder let content: Content

    private var verticalPadding: CGFloat { layoutMetrics.adaptive(18) }
    private var horizontalPadding: CGFloat { layoutMetrics.adaptive(20) }

    var body: some View {
        content
            .padding(.top, verticalPadding)
            .padding(.bottom, verticalPadding)
            .padding(.leading, horizontalPadding)
            .padding(.trailing, horizontalPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LiquidGlassBackground(gradient: gradient))
            .clipShape(RoundedRectangle(cornerRadius: layoutMetrics.adaptive(32), style: .continuous))
            .overlay(HeaderBorderOverlay())
            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
            .overlay(alignment: .top) {
                if showPremiumButton {
                    PremiumButton(action: { onPremiumTap?() }, color: .white)
                        .scaleEffect(0.8)
                        .padding(.top, verticalPadding)
                }
            }
    }
}
