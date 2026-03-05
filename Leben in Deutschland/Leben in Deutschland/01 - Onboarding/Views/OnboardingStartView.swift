import SwiftUI

/// Splash screen: app name and icon, then auto-advances.
struct OnboardingStartView: View {
    let onComplete: () -> Void
    @State private var glowPhase: Bool = false

    var body: some View {
        ZStack {
            // Same diagonal gradient as home screen header
            Rectangle()
                .fill(LiquidGlassGradient.blue.screenBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("HERO")
                        .font(
                            .system(size: 90, weight: .heavy)
                                .width(.expanded)
                        )
                        .kerning(2)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .allowsTightening(true)
                        .truncationMode(.tail)
                        .foregroundColor(.white)
                        .padding(.bottom, -4)
                    Text("Einbürgerungtest")
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
                    MascotView(autoPlayInterval: 4)
                        .fixedSize()
                        .scaleEffect(glowPhase ? 1.04 : 1.0)
                        .shadow(
                            color: .black.opacity(glowPhase ? 0.2 : 0.08),
                            radius: glowPhase ? 16 : 6,
                            x: 0,
                            y: glowPhase ? 10 : 4
                        )
                    Spacer()
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                glowPhase = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onComplete()
            }
        }
    }
}

#Preview {
    OnboardingStartView {
        print("Start completed")
    }
}
