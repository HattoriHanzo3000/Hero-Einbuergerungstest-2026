//
//  ConfettiOverlay.swift
//  Leben in Deutschland
//
//  Full-screen confetti burst; respects Reduce Motion (hidden when enabled).
//

import SwiftUI

struct ConfettiOverlay: View {
    /// Timeline length so pieces can fall the full height and exit below the bottom edge.
    static let animationRunDuration: TimeInterval = 8.5
    /// Remove the overlay from the hierarchy just after the canvas stops (see `SettingsHeroProPlanView`).
    static let overlayRemovalDelay: TimeInterval = animationRunDuration + 0.2

    var isActive: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if isActive && !reduceMotion {
            ConfettiBurstCanvas()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Canvas burst

private struct ConfettiBurstCanvas: View {
    @State private var startDate = Date()

    private var palette: [Color] {
        [
            Color("AppBlue"),
            Color("AppBlueThird"),
            Color.white.opacity(0.95),
            Color.yellow.opacity(0.88),
            Color.pink.opacity(0.78),
        ]
    }

    var body: some View {
        GeometryReader { _ in
            TimelineView(.animation(minimumInterval: 1.0 / 45.0)) { timeline in
                Canvas { context, size in
                    let elapsed = timeline.date.timeIntervalSince(startDate)
                    guard elapsed < ConfettiOverlay.animationRunDuration else { return }

                    // Brief fade-in only; no fade-out — pieces stay visible until they pass below the bottom.
                    let masterOpacity = min(1.0, elapsed * 5.0)

                    for i in 0..<72 {
                        let seed = Double(i)
                        let stagger = (seed.truncatingRemainder(dividingBy: 11.0)) * 0.045
                        let t = max(0, elapsed - stagger)
                        let xNorm = (sin(seed * 2.17 + 0.4) * 0.5 + 0.5) * 0.92 + 0.04
                        let xBase = CGFloat(xNorm) * size.width
                        let sway = CGFloat(sin(t * 5.0 + seed * 1.3) * 0.06 * Double(size.width))
                        let x = xBase + sway

                        let fallSpeed = 145.0 + seed.truncatingRemainder(dividingBy: 9.0) * 14.0
                        let spawnAboveScreen: CGFloat = -100
                        let y = spawnAboveScreen + CGFloat(t) * fallSpeed + CGFloat(sin(t * 2.0 + seed) * 18.0)

                        guard y < size.height + 100 else { continue }

                        let w = 4.0 + CGFloat(i % 5) * 2.0
                        let h = 6.0 + CGFloat((i + 3) % 6) * 2.5
                        let rotation = Angle.degrees((seed * 41.0 + t * 220.0).truncatingRemainder(dividingBy: 360.0))

                        var piece = context
                        piece.opacity = masterOpacity
                        piece.translateBy(x: x, y: y)
                        piece.rotate(by: rotation)
                        let rect = CGRect(x: -w / 2, y: -h / 2, width: w, height: h)
                        piece.fill(
                            Path(roundedRect: rect, cornerRadius: 1.5, style: .continuous),
                            with: .color(palette[i % palette.count])
                        )
                    }
                }
            }
            .onAppear { startDate = Date() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
