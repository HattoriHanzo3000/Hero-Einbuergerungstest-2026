import SwiftUI

// MARK: - Quiz Answer Option Button
/// Reusable glowing answer option used across quiz-style flows.
/// Supports primary/secondary text, animated glow states, and adaptive styling.
struct QuizAnswerOptionButton: View {
    enum State: Equatable {
        case neutral
        case selected
        case correct
        case incorrect
    }
    
    struct Style {
        let primaryTextColor: Color
        let secondaryTextColor: Color
        let neutralBackground: Color
        let selectedBackground: Color
        let correctBackground: Color
        let incorrectBackground: Color
        let neutralGlow: Color
        let selectedGlow: Color
        let correctGlow: Color
        let incorrectGlow: Color
        let cornerRadius: CGFloat
        let horizontalPadding: CGFloat
        let verticalPadding: CGFloat
        
        static var standard: Style {
            Style(
                primaryTextColor: Color(.label),
                secondaryTextColor: Color(.secondaryLabel),
                neutralBackground: Color(.systemGray5),
                selectedBackground: Color(.systemBlue),
                correctBackground: Color(.systemGreen),
                incorrectBackground: Color(.systemRed),
                neutralGlow: .clear,
                selectedGlow: Color(.systemBlue).opacity(0.45),
                correctGlow: Color(.systemGreen).opacity(0.45),
                incorrectGlow: Color(.systemRed).opacity(0.45),
                cornerRadius: 18,
                horizontalPadding: 18,
                verticalPadding: 16
            )
        }
    }
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    let primaryText: String
    let secondaryText: String?
    let state: State
    let style: Style
    let isEnabled: Bool
    let accessibilityLabel: String?
    let accessibilityHint: String?
    let suppressGlow: Bool
    let action: () -> Void
    
    init(
        primaryText: String,
        secondaryText: String? = nil,
        state: State,
        style: Style = .standard,
        isEnabled: Bool = true,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        suppressGlow: Bool = false,
        action: @escaping () -> Void
    ) {
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.state = state
        self.style = style
        self.isEnabled = isEnabled
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.suppressGlow = suppressGlow
        self.action = action
    }
    
    var body: some View {
        buttonContent
    }
}

private extension QuizAnswerOptionButton {
    @ViewBuilder
    var buttonContent: some View {
        let baseButton = Button(action: action) {
            labelContent
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, layoutMetrics.adaptive(style.horizontalPadding))
                .padding(.vertical, layoutMetrics.adaptive(style.verticalPadding))
                .background(backgroundLayer)
                .shadow(color: glowColor, radius: glowRadius, y: glowOffset)
        }
        .buttonStyle(.plain)
        .disabled(isEnabled == false)
        .accessibilityAddTraits(.isButton)
        
        if let accessibilityLabel {
            if let accessibilityHint {
                baseButton.accessibilityLabel(Text(accessibilityLabel))
                    .accessibilityHint(Text(accessibilityHint))
            } else {
                baseButton.accessibilityLabel(Text(accessibilityLabel))
            }
        } else if let accessibilityHint {
            baseButton.accessibilityHint(Text(accessibilityHint))
        } else {
            baseButton
        }
    }
    
    var labelContent: some View {
        VStack(alignment: .leading, spacing: layoutMetrics.adaptive(6)) {
            Text(primaryText)
                .font(.system(.body, design: .rounded).weight(.regular))
                .foregroundColor(style.primaryTextColor)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
            
            if let secondaryText, secondaryText.isEmpty == false {
                Text(secondaryText)
                    .font(.system(.footnote, design: .rounded).weight(.regular))
                    .foregroundColor(style.secondaryTextColor)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
            }
        }
    }
    
    var backgroundLayer: some View {
        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(style.cornerRadius), style: .continuous)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(style.cornerRadius), style: .continuous)
                    .fill(backgroundColor)
                    .opacity(0.9)
            )
    }
    
    var backgroundColor: Color {
        switch state {
        case .neutral:
            return style.neutralBackground
        case .selected:
            return style.selectedBackground
        case .correct:
            return style.correctBackground
        case .incorrect:
            return style.incorrectBackground
        }
    }
    
    var glowColor: Color {
        guard !suppressGlow else { return .clear }
        guard colorScheme == .dark else { return .clear }
        switch state {
        case .neutral:
            return style.neutralGlow
        case .selected:
            return style.selectedGlow
        case .correct:
            return style.correctGlow
        case .incorrect:
            return style.incorrectGlow
        }
    }
    
    var glowRadius: CGFloat {
        glowColor == .clear ? 0 : layoutMetrics.adaptive(20)
    }
    
    var glowOffset: CGFloat {
        glowColor == .clear ? 0 : layoutMetrics.adaptive(6)
    }
    
}

// MARK: - Preview
struct QuizAnswerOptionButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            QuizAnswerOptionButton(
                primaryText: "Das Recht auf freie Meinungsäußerung",
                state: .neutral
            ) {}
            
            QuizAnswerOptionButton(
                primaryText: "Das Recht auf freie Meinungsäußerung",
                secondaryText: "Freedom of speech",
                state: .selected
            ) {}
            
            QuizAnswerOptionButton(
                primaryText: "Das Recht auf freie Meinungsäußerung",
                state: .correct
            ) {}
            
            QuizAnswerOptionButton(
                primaryText: "Das Recht auf freie Meinungsäußerung",
                state: .incorrect
            ) {}
        }
        .padding()
        
        .preferredColorScheme(.dark)
    }
}

