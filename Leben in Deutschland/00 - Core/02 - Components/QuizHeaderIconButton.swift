import SwiftUI

// MARK: - Quiz Header Icon Button
/// A circular icon control used in question card header cards (e.g., translation toggle, favorites).
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
    
    /// Matches back arrow: icon 20pt, fixed 40pt circle (reference size).
    private var iconSize: CGFloat { layoutMetrics.adaptive(20) }
    private var circleSize: CGFloat { layoutMetrics.adaptive(40) }
    
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

// MARK: - Convenience Factories
extension QuizHeaderIconButton {
    /// Translation toggle (globe icon) with standard quiz header styling.
    static func translation(isActive: Bool, action: @escaping () -> Void) -> QuizHeaderIconButton {
        QuizHeaderIconButton(
            systemName: "globe",
            isActive: isActive,
            activeTint: AppActionIconColors.translationActive,
            inactiveTint: .white,
            showGlow: false,
            showStroke: false,
            accessibilityLabel: "spaced_translation_button_accessibility_label".localized,
            accessibilityHint: nil,
            action: action
        )
    }
    
    /// Favorite toggle (heart icon) with standard quiz header styling.
    static func favorite(isActive: Bool, action: @escaping () -> Void) -> QuizHeaderIconButton {
        QuizHeaderIconButton(
            systemName: "heart",
            isActive: isActive,
            activeTint: AppActionIconColors.favoriteActive,
            inactiveTint: .white,
            showGlow: false,
            showStroke: false,
            useFilledWhenActive: true,
            accessibilityLabel: "spaced_favorite_button_accessibility_label".localized,
            accessibilityHint: nil,
            action: action
        )
    }
}

private extension QuizHeaderIconButton {
    @ViewBuilder
    var buttonContent: some View {
        let baseButton = Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .semibold))
                .symbolVariant(useFilledWhenActive && isActive ? .fill : .none)
                .foregroundColor(isActive ? activeTint : (inactiveTint ?? .white))
                .frame(width: circleSize, height: circleSize)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.18))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
        .animation(.easeInOut(duration: 0.25), value: isActive)
        
        if let accessibilityHint {
            baseButton.accessibilityHint(accessibilityHint)
        } else {
            baseButton
        }
    }
}

// MARK: - Preview
struct QuizHeaderIconButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            QuizHeaderIconButton.translation(isActive: true) {}
                .padding()
                .preferredColorScheme(.dark)
            
            QuizHeaderIconButton.favorite(isActive: false) {}
                .padding()
                .preferredColorScheme(.dark)
        }
    }
}

