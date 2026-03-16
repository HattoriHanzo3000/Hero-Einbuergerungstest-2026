import SwiftUI

/// Splash screen: app name and icon, then auto-advances after mascot GIF plays once.
struct OnboardingStartView: View {
    let onComplete: () -> Void
    @State private var playSignal: UUID?

    var body: some View {
        ZStack {
            // Same diagonal gradient as home screen header
            Rectangle()
                .fill(LiquidGlassGradient.blue.screenBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 4) {
                    heroTitleView
                        .padding(.bottom, -4)
                    Text("Einbürgerungstest")
                        .font(.system(size: 40, weight: .heavy))
                        .kerning(0.5)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .allowsTightening(true)
                        .truncationMode(.tail)
                        .foregroundColor(.white)
                        .accessibilityAddTraits(.isHeader)
                    Text("Alle aktuellen Prüfungsfragen für 2026")
                        .font(.system(size: 22, weight: .semibold).italic())
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .allowsTightening(true)
                        .truncationMode(.tail)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 40)

                HStack {
                    Spacer()
                    MascotView(
                        assetBaseName: "MainChick",
                        autoPlayInterval: nil,
                        playSignal: playSignal,
                        onPlayCompleted: onComplete
                    )
                    .environment(\.colorScheme, .light)
                    .fixedSize()
                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
                    Spacer()
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                playSignal = UUID()
            }
        }
    }

    private var heroTitleView: some View {
        let title = "HERO"
        let font = Font.system(size: 90, weight: .heavy).width(.expanded)
        let styledText = Text(title)
            .font(font)
            .kerning(2)
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .allowsTightening(true)
            .truncationMode(.tail)
        return styledText
            .foregroundColor(Color("AppAmber"))
            .overlay(
                ShimmerOverlay(duration: 3)
                    .mask(styledText)
                    .blendMode(.plusLighter)
            )
    }
}

#Preview {
    OnboardingStartView {
        print("Start completed")
    }
}
