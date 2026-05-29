//
//  PaywallWindowConfettiPresenter.swift
//  Leben in Deutschland
//
//  Full-screen confetti above the paywall sheet (and all UI) via a high-level pass-through window.
//

import SwiftUI
import UIKit

/// Presents `ConfettiOverlay` in a separate `UIWindow` so it sits above SwiftUI `.sheet` content.
/// Touches pass through to views below.
enum PaywallWindowConfettiPresenter {
    private static var overlayWindow: UIWindow?

    @MainActor
    static func show() {
        guard overlayWindow == nil else { return }
        guard let scene = activeWindowScene() else { return }

        let window = PassthroughConfettiWindow(windowScene: scene)
        window.windowLevel = .alert + 1
        window.backgroundColor = .clear
        window.isUserInteractionEnabled = false

        let host = UIHostingController(rootView: PaywallWindowConfettiRootView())
        host.view.backgroundColor = .clear
        window.rootViewController = host
        window.isHidden = false
        overlayWindow = window
    }

    @MainActor
    static func hide() {
        overlayWindow?.isHidden = true
        overlayWindow = nil
    }

    private static func activeWindowScene() -> UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first
    }
}

// MARK: - Window (pass-through touches)

private final class PassthroughConfettiWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        nil
    }
}

// MARK: - SwiftUI root

private struct PaywallWindowConfettiRootView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if !reduceMotion {
                ConfettiOverlay(isActive: true)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
