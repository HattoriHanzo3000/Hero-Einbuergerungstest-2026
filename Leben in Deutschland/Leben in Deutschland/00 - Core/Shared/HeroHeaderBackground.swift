import SwiftUI

// MARK: - Hero Header Background
/// Gradient background used for hero headers across feature screens.
struct HeroHeaderBackground: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color("AppBlueLagoon").opacity(0.45),
                        Color("AppBlueLagoon").opacity(0.18),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(infiniteCloudsOverlay)
    }
}

private extension HeroHeaderBackground {
    var infiniteCloudsOverlay: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0.08),
                Color.white.opacity(0.02),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Preview
#Preview {
    HeroHeaderBackground()
        .frame(height: 200)
        .padding()
        .background(Color(.systemBackground))
}

