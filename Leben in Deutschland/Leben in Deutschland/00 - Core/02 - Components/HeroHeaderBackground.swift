import SwiftUI

// MARK: - Hero Header Background
/// Gradient background matching screen headers. Uses shared LiquidGlassBackground.
struct HeroHeaderBackground: View {
    var body: some View {
        LiquidGlassBackground(gradient: .blue)
    }
}

// MARK: - Preview
#Preview {
    HeroHeaderBackground()
        .frame(height: 200)
        .padding()
        .background(Color(.systemBackground))
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

