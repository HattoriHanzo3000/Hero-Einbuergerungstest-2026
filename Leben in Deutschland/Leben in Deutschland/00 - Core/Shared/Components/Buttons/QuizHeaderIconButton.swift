import SwiftUI

// MARK: - Quiz Header Icon Button
/// A circular icon control used in quiz-style headers (e.g., translation toggle, favorites).
/// Keeps the glass background, glow animation, and accessibility traits consistent.
struct QuizHeaderIconButton: View {
    let systemName: String
    let isActive: Bool
    let activeTint: Color
    let inactiveTint: Color?
    let showGlow: Bool
    let showStroke: Bool
    let useFilledWhenActive: Bool
    let accessibilityLabel: String
    let accessibilityHint: String?
    let action: () -> Void
    
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    private var iconSize: CGFloat { layoutMetrics.adaptive(18) }
    private var containerSize: CGFloat { layoutMetrics.adaptive(38) }
    
    init(
        systemName: String,
        isActive: Bool,
        activeTint: Color,
        inactiveTint: Color? = nil,
        showGlow: Bool = true,
        showStroke: Bool = true,
        useFilledWhenActive: Bool = false,
        accessibilityLabel: String,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.systemName = systemName
        self.isActive = isActive
        self.activeTint = activeTint
        self.inactiveTint = inactiveTint
        self.showGlow = showGlow
        self.showStroke = showStroke
        self.useFilledWhenActive = useFilledWhenActive
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.action = action
    }
    
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
                    .overlay(glowMask.opacity(showGlow && isActive ? 1 : 0))
                    .overlay(
                        Group {
                            if showStroke {
                                Circle()
                                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
                            }
                        }
                    )
                    .shadow(
                        color: showGlow ? activeTint.opacity(isActive ? 0.55 : 0) : .clear,
                        radius: showGlow && isActive ? layoutMetrics.adaptive(22) : 0,
                        y: showGlow && isActive ? layoutMetrics.adaptive(4) : 0
                    )
                    .frame(width: containerSize, height: containerSize)
                
                Image(systemName: systemName)
                    .font(.system(size: iconSize, weight: .semibold))
                    .symbolVariant(useFilledWhenActive && isActive ? .fill : .none)
                    .foregroundStyle(isActive ? activeTint : (inactiveTint ?? Color(.systemGray6)))
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
                activeTint: Color("AppOrange"),
                accessibilityLabel: "Sprachoption ändern",
                accessibilityHint: "Wechsle zwischen Originaltext und Übersetzung."
            ) {}
            .padding()
            
            .preferredColorScheme(.dark)
            
            QuizHeaderIconButton(
                systemName: "heart",
                isActive: false,
                activeTint: Color("AppPink"),
                useFilledWhenActive: true,
                accessibilityLabel: "Zu Favoriten hinzufügen",
                accessibilityHint: nil
            ) {}
            .padding()
            
            .preferredColorScheme(.dark)
        }
    }
}

