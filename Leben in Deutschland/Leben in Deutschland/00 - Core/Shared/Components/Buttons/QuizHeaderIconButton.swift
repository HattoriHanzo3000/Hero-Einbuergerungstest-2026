import SwiftUI

// MARK: - Quiz Header Icon Button
/// A circular icon control used in quiz-style headers (e.g., translation toggle, favorites).
/// Keeps the glass background, glow animation, and accessibility traits consistent.
struct QuizHeaderIconButton: View {
    let systemName: String
    let isActive: Bool
    let activeTint: Color
    let accessibilityLabel: String
    let accessibilityHint: String?
    let action: () -> Void
    
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    private var iconSize: CGFloat { layoutMetrics.adaptive(18) }
    private var containerSize: CGFloat { layoutMetrics.adaptive(38) }
    
    var body: some View {
        buttonContent
    }
}

private extension QuizHeaderIconButton {
    @ViewBuilder
    var buttonContent: some View {
        let baseButton = Button(action: action) {
            ZStack {
                Circle()
                    .fill(.thinMaterial)
                    .overlay(glowMask.opacity(isActive ? 1 : 0))
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )
                    .shadow(
                        color: activeTint.opacity(isActive ? 0.55 : 0),
                        radius: isActive ? layoutMetrics.adaptive(22) : 0,
                        y: isActive ? layoutMetrics.adaptive(4) : 0
                    )
                    .frame(width: containerSize, height: containerSize)
                
                Image(systemName: systemName)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(Color(.systemGray6))
            }
            .frame(width: containerSize, height: containerSize)
            .animation(.easeInOut(duration: 0.25), value: isActive)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
        
        if let accessibilityHint {
            baseButton.accessibilityHint(accessibilityHint)
        } else {
            baseButton
        }
    }
    
    var glowMask: some View {
        RadialGradient(
            colors: [
                activeTint.opacity(0.8),
                activeTint.opacity(0.12),
                Color.clear
            ],
            center: .center,
            startRadius: 0,
            endRadius: containerSize * 0.95
        )
        .clipShape(Circle())
    }
}

// MARK: - Preview
struct QuizHeaderIconButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            QuizHeaderIconButton(
                systemName: "globe",
                isActive: true,
                activeTint: .orange,
                accessibilityLabel: "Sprachoption ändern",
                accessibilityHint: "Wechsle zwischen Originaltext und Übersetzung."
            ) {}
            .padding()
            
            .preferredColorScheme(.dark)
            
            QuizHeaderIconButton(
                systemName: "heart",
                isActive: false,
                activeTint: .pink,
                accessibilityLabel: "Zu Favoriten hinzufügen",
                accessibilityHint: nil
            ) {}
            .padding()
            
            .preferredColorScheme(.dark)
        }
    }
}

