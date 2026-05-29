import SwiftUI

// MARK: - Background Modifier Chain
private struct QuizActionButtonBackgroundModifier: ViewModifier {
    let shape: RoundedRectangle
    let isEnabled: Bool
    let layoutMetrics: LayoutMetrics

    func body(content: Content) -> some View {
        content
            .overlay(shape.stroke(Color.white.opacity(0.18), lineWidth: 1))
            .clipShape(shape)
            .shadow(
                color: Color.black.opacity(isEnabled ? 0.16 : 0.08),
                radius: layoutMetrics.adaptive(22),
                y: layoutMetrics.adaptive(10)
            )
    }
}

// MARK: - Quiz Action Button
/// A reusable rounded button used across quiz and test flows.
/// It keeps typography, layout, and subtle glass styling consistent while allowing
/// callers to customize text, fill colors, and halo glow.
struct QuizActionButton: View {
    struct Style {
        let backgroundColor: Color
        let disabledBackgroundColor: Color
        let haloPrimaryColor: Color
        let haloSecondaryColor: Color
        let showsHaloWhenDisabled: Bool
        let suppressGlow: Bool
        /// When set, uses LiquidGlassBackground (gradient + material) matching the header card.
        let gradient: LiquidGlassGradient?

        init(
            backgroundColor: Color,
            disabledBackgroundColor: Color,
            haloPrimaryColor: Color,
            haloSecondaryColor: Color,
            showsHaloWhenDisabled: Bool = false,
            suppressGlow: Bool = false,
            gradient: LiquidGlassGradient? = nil
        ) {
            self.backgroundColor = backgroundColor
            self.disabledBackgroundColor = disabledBackgroundColor
            self.haloPrimaryColor = haloPrimaryColor
            self.haloSecondaryColor = haloSecondaryColor
            self.showsHaloWhenDisabled = showsHaloWhenDisabled
            self.suppressGlow = suppressGlow
            self.gradient = gradient
        }
    }
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    private let titleKey: LocalizedStringKey?
    private let titleText: String?
    private let action: () -> Void
    private let style: Style
    private let isEnabled: Bool
    private let accessibilityLabel: String?
    
    init(
        _ title: LocalizedStringKey,
        style: Style,
        isEnabled: Bool = true,
        accessibilityLabel: String? = nil,
        action: @escaping () -> Void
    ) {
        self.titleKey = title
        self.titleText = nil
        self.style = style
        self.isEnabled = isEnabled
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }
    
    init(
        _ title: String,
        style: Style,
        isEnabled: Bool = true,
        accessibilityLabel: String? = nil,
        action: @escaping () -> Void
    ) {
        self.titleKey = nil
        self.titleText = title
        self.style = style
        self.isEnabled = isEnabled
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }
    
    var body: some View {
        buttonContent
    }
}

private extension QuizActionButton {
    @ViewBuilder
    var buttonContent: some View {
        let baseButton = Button(action: action) {
            labelContent
                .foregroundColor(.white)
                .padding(.vertical, layoutMetrics.adaptive(18))
                .frame(maxWidth: .infinity)
                .background(backgroundLayer)
                .overlay(borderLayer)
                .opacity(isEnabled ? 1 : 0.75)
                .scaleEffect(isEnabled ? 1 : 0.98)
                .animation(.spring(response: 0.45, dampingFraction: 0.82), value: isEnabled)
                .shadow(color: primaryGlowColor, radius: primaryGlowRadius, y: primaryGlowOffset)
                .shadow(color: secondaryGlowColor, radius: secondaryGlowRadius, y: secondaryGlowOffset)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
        .disabled(isEnabled == false)
        
        if let label = accessibilityLabelText {
            baseButton.accessibilityLabel(label)
        } else {
            baseButton
        }
    }
    
    var accessibilityLabelText: Text? {
        if let accessibilityLabel {
            return Text(accessibilityLabel)
        }
        if let titleText {
            return Text(verbatim: titleText)
        }
        if let titleKey {
            return Text(titleKey)
        }
        return nil
    }
    
    var labelContent: some View {
        Group {
            if let titleKey {
                Text(titleKey)
            } else if let titleText {
                Text(verbatim: titleText)
            }
        }
        .font(.system(.headline, weight: .bold))
        .fontDesign(.default)
        .multilineTextAlignment(.center)
        .minimumScaleFactor(0.85)
        .allowsTightening(true)
    }
    
    @ViewBuilder
    var backgroundLayer: some View {
        let cornerRadius = layoutMetrics.adaptive(28)
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let modifier = QuizActionButtonBackgroundModifier(
            shape: shape,
            isEnabled: isEnabled,
            layoutMetrics: layoutMetrics
        )

        if let gradient = style.gradient {
            shape
                .fill(gradient.screenBackground)
                .overlay(highlightOverlay)
                .modifier(modifier)
        } else {
            ZStack {
                shape.fill(.ultraThinMaterial)
                shape.fill(isEnabled ? style.backgroundColor : style.disabledBackgroundColor)
            }
            .modifier(modifier)
        }
    }

    private var highlightOverlay: some View {
        Rectangle().fill(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.20),
                    Color.white.opacity(0.05),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    var borderLayer: some View {
        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(28), style: .continuous)
            .stroke(Color.white.opacity(0.12), lineWidth: 0.4)
            .blendMode(.plusLighter)
    }
    
    var shouldShowGlow: Bool {
        guard !style.suppressGlow else { return false }
        guard colorScheme == .dark else { return false }
        if isEnabled {
            return true
        }
        return style.showsHaloWhenDisabled
    }
    
    var primaryGlowColor: Color {
        shouldShowGlow ? style.haloPrimaryColor : .clear
    }
    
    var secondaryGlowColor: Color {
        shouldShowGlow ? style.haloSecondaryColor : .clear
    }
    
    var primaryGlowRadius: CGFloat {
        shouldShowGlow ? layoutMetrics.adaptive(26) : 0
    }
    
    var secondaryGlowRadius: CGFloat {
        shouldShowGlow ? layoutMetrics.adaptive(12) : 0
    }
    
    var primaryGlowOffset: CGFloat {
        shouldShowGlow ? layoutMetrics.adaptive(10) : 0
    }
    
    var secondaryGlowOffset: CGFloat {
        shouldShowGlow ? layoutMetrics.adaptive(2) : 0
    }
}

// MARK: - Preview
struct QuizActionButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            QuizActionButton(
                "Check Answer",
                style: .init(
                    backgroundColor: Color("AppBlueLagoon"),
                    disabledBackgroundColor: Color(.systemGray4).opacity(0.95),
                    haloPrimaryColor: Color("AppBlueLagoon").opacity(0.36),
                    haloSecondaryColor: Color.white.opacity(0.18)
                )
            ) {}
            .padding()
            
            .preferredColorScheme(.dark)
            
            QuizActionButton(
                "Get Hint",
                style: .init(
                    backgroundColor: Color(uiColor: .systemOrange),
                    disabledBackgroundColor: Color(uiColor: .systemOrange),
                    haloPrimaryColor: Color(uiColor: .systemOrange).opacity(0.42),
                    haloSecondaryColor: Color.white.opacity(0.18)
                )
            ) {}
            .padding()
            
            .preferredColorScheme(.dark)
        }
    }
}

