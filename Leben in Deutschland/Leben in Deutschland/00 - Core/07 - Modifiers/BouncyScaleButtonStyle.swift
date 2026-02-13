//
//  BouncyScaleButtonStyle.swift
//  Leben in Deutschland
//
//  Playful press scale for a friendly, cartoon-like feel.
//  Shared across HomeLearnOptionsSection.
//

import SwiftUI

/// Button style that scales down on press with a spring animation.
struct BouncyScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
