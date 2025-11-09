import SwiftUI

// Reusable settings button component
struct SettingsButton<TrailingContent: View>: View {
    let icon: String
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () -> Void
    let trailingContent: () -> TrailingContent
    
    @State private var isPressed = false
    
    init(
        icon: String,
        title: String,
        backgroundColor: Color = Color(.systemGray5),
        foregroundColor: Color = .primary,
        action: @escaping () -> Void,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() }
    ) {
        self.icon = icon
        self.title = title
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.action = action
        self.trailingContent = trailingContent
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(.body, design: .rounded).weight(.medium))
                .foregroundColor(foregroundColor)
                .frame(width: 20)
            
            Text(title)
                .font(.system(.body, design: .rounded).weight(.medium))
                .foregroundColor(foregroundColor)
            
            Spacer()
            
            trailingContent()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
        )
    
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.08), value: isPressed)
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: {
                action()
            }
        )
    }
}

// Extension for common button types
extension SettingsButton where TrailingContent == EmptyView {
    // Simple button with no trailing content
    init(
        icon: String,
        title: String,
        backgroundColor: Color = Color(.systemGray5),
        foregroundColor: Color = .primary,
        action: @escaping () -> Void
    ) {
        self.init(
            icon: icon,
            title: title,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            action: action,
            trailingContent: { EmptyView() }
        )
    }
}

extension SettingsButton where TrailingContent == Text {
    // Button with text trailing content
    init(
        icon: String,
        title: String,
        trailingText: String,
        trailingColor: Color = .secondary,
        trailingWeight: Font.Weight = .medium,
        backgroundColor: Color = Color(.systemGray5),
        foregroundColor: Color = .primary,
        action: @escaping () -> Void
    ) {
        self.init(
            icon: icon,
            title: title,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            action: action,
            trailingContent: {
                Text(trailingText)
                    .font(.system(.body, design: .rounded).weight(trailingWeight))
                    .foregroundColor(trailingColor)
            }
        )
    }
}


