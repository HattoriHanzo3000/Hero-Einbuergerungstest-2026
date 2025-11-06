import SwiftUI

// MARK: - View Extension - Glass Effect (iOS 26 Liquid Glass)
extension View {
    /// Applies iOS 26 Liquid Glass effect with material background and subtle border
    /// Works best with RoundedRectangle shapes
    func glassEffect() -> some View {
        self
            .background(.ultraThinMaterial)
            .overlay {
                // Subtle border for depth
                RoundedRectangle(cornerRadius: 0)
                    .stroke(.white.opacity(0.15), lineWidth: 0.5)
            }
    }
}

