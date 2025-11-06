//
//  NoEffectButtonStyle.swift
//  Leben in Deutschland
//
//  Button style that prevents system visual effects (opacity, scale, etc.)
//  Use with custom press animations for full control
//

import SwiftUI

/// A button style that prevents any system visual effects
/// Use this for custom buttons that handle their own press states
struct NoEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // No opacity, color, or scale changes - completely static
    }
}

