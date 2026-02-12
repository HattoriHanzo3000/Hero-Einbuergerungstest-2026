//
//  LiquidGlassBackground.swift
//  Leben in Deutschland
//
//  Shared gradient background for headers. Used by screen headers and question card headers.
//

import SwiftUI

// MARK: - Liquid Glass Gradient
enum LiquidGlassGradient {
    case blue
    case orange
}

// MARK: - Liquid Glass Background
struct LiquidGlassBackground: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    var gradient: LiquidGlassGradient = .blue

    var body: some View {
        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(32), style: .continuous)
            .fill(mainGradient)
            .overlay(highlightOverlay)
    }

    private var mainGradient: LinearGradient {
        switch gradient {
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
                    Color(red: 0.77, green: 0.21, blue: 0.12).opacity(0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
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
