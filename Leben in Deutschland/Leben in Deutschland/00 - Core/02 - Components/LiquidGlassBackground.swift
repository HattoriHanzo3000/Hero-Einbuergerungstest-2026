//
//  LiquidGlassBackground.swift
//  Leben in Deutschland
//
//  Shared gradient background for header cards. Used by ScreenHeaderCard, QuestionCardHeaderCard, etc.
//

import SwiftUI

// MARK: - Liquid Glass Gradient
enum LiquidGlassGradient {
    case blue
    case orange
    case green
    case red
    case amber
}

// MARK: - Screen Header Gradient (full-width header background, shared across screens)
extension LiquidGlassGradient {
    /// Linear gradient for screen header areas (Categories, Test Results, etc.). Single source of truth.
    var screenBackground: LinearGradient {
        switch self {
        case .blue:
            return LinearGradient(
                colors: [
                    Color("AppBlueLagoon").opacity(0.9),
                    Color("AppBlueLagoon").opacity(0.65),
                    Color("AppCaribean").opacity(0.45)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .orange:
            return LinearGradient(
                colors: [
                    Color("AppOrange").opacity(0.95),
                    Color("AppOrange").opacity(0.75),
                    Color("AppOrange").opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .green:
            return LinearGradient(
                colors: [
                    Color("AppGreen").opacity(0.9),
                    Color("AppGreen").opacity(0.65),
                    Color("AppGreen").opacity(0.45)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .red:
            return LinearGradient(
                colors: [
                    Color.red.opacity(0.9),
                    Color.red.opacity(0.65),
                    Color(red: 0.9, green: 0.2, blue: 0.2).opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .amber:
            return LinearGradient(
                colors: [
                    Color("AppAmber").opacity(0.95),
                    Color("AppAmber").opacity(0.75),
                    Color("AppAmber").opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Liquid Glass Background
struct LiquidGlassBackground: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    var gradient: LiquidGlassGradient = .blue

    var body: some View {
        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(32), style: .continuous)
            .fill(gradient.screenBackground)
            .overlay(highlightOverlay)
    }

    private var highlightOverlay: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0.20),
                Color.white.opacity(0.05),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

}

// MARK: - Header Border Overlay
struct HeaderBorderOverlay: View {
    @Environment(\.layoutMetrics) private var layoutMetrics

    var body: some View {
        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(32), style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [.white.opacity(0.4), .white.opacity(0.08)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 0.8
            )
    }
}

// MARK: - Preview
#Preview("Blue") {
    LiquidGlassBackground(gradient: .blue)
        .frame(height: 120)
        .padding()
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

#Preview("Orange") {
    LiquidGlassBackground(gradient: .orange)
        .frame(height: 120)
        .padding()
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

#Preview("Green") {
    LiquidGlassBackground(gradient: .green)
        .frame(height: 120)
        .padding()
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

#Preview("Red") {
    LiquidGlassBackground(gradient: .red)
        .frame(height: 120)
        .padding()
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

#Preview("Amber") {
    LiquidGlassBackground(gradient: .amber)
        .frame(height: 120)
        .padding()
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
