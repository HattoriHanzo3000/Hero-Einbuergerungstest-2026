import SwiftUI

// MARK: - Settings List Row
/// iOS 26 inspired list row with Liquid Glass styling.
struct SettingsListRow<TrailingContent: View>: View {
    let icon: String
    let title: String
    let tintColor: Color
    let foregroundColor: Color
    let showsChevron: Bool
    let action: () -> Void
    let trailingContent: () -> TrailingContent
    
    @State private var isPressed = false
    
    init(
        icon: String,
        title: String,
        tintColor: Color = .accentColor,
        foregroundColor: Color = .primary,
        showsChevron: Bool = false,
        action: @escaping () -> Void,
        @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() }
    ) {
        self.icon = icon
        self.title = title
        self.tintColor = tintColor
        self.foregroundColor = foregroundColor
        self.showsChevron = showsChevron
        self.action = action
        self.trailingContent = trailingContent
    }
    
    var body: some View {
        let cornerRadius = MainScreenConstants.adaptiveValue(24)
        
        Button(action: {
            HapticManager.shared.lightImpact()
            action()
        }) {
            HStack(spacing: MainScreenConstants.adaptiveValue(16)) {
                iconContainer
                
                Text(title)
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .foregroundStyle(foregroundColor)
                
                Spacer(minLength: MainScreenConstants.adaptiveValue(12))
                
                trailingContent()
                    .font(.system(.callout, design: .rounded).weight(.medium))
                
                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: MainScreenConstants.adaptiveValue(14), weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.secondary.opacity(0.7))
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, MainScreenConstants.adaptiveValue(18))
            .padding(.vertical, MainScreenConstants.adaptiveValue(14))
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.6),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.9
                            )
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 18, y: 10)
            )
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.easeOut(duration: 0.12), value: isPressed)
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: {}
        )
        .accessibilityElement(children: .combine)
    }
    
    private var iconContainer: some View {
        let iconSize = MainScreenConstants.adaptiveValue(42)
        let iconCornerRadius = MainScreenConstants.adaptiveValue(16)
        
        return ZStack {
            RoundedRectangle(cornerRadius: iconCornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            tintColor.opacity(0.28),
                            tintColor.opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: iconCornerRadius, style: .continuous)
                        .stroke(tintColor.opacity(0.3), lineWidth: 0.8)
                )
                .shadow(color: tintColor.opacity(0.22), radius: 12, y: 6)
            
            Image(systemName: icon)
                .font(.system(size: MainScreenConstants.adaptiveValue(19), weight: .semibold, design: .rounded))
                .foregroundStyle(tintColor.opacity(0.9))
        }
        .frame(width: iconSize, height: iconSize)
    }
}

// MARK: - Convenience Initialisers
extension SettingsListRow where TrailingContent == EmptyView {
    init(
        icon: String,
        title: String,
        tintColor: Color = .accentColor,
        foregroundColor: Color = .primary,
        showsChevron: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(
            icon: icon,
            title: title,
            tintColor: tintColor,
            foregroundColor: foregroundColor,
            showsChevron: showsChevron,
            action: action,
            trailingContent: { EmptyView() }
        )
    }
}

extension SettingsListRow where TrailingContent == Text {
    init(
        icon: String,
        title: String,
        trailingText: String,
        trailingColor: Color = .secondary,
        trailingWeight: Font.Weight = .medium,
        tintColor: Color = .accentColor,
        foregroundColor: Color = .primary,
        showsChevron: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(
            icon: icon,
            title: title,
            tintColor: tintColor,
            foregroundColor: foregroundColor,
            showsChevron: showsChevron,
            action: action,
            trailingContent: {
                Text(trailingText)
                    .font(.system(.callout, design: .rounded).weight(trailingWeight))
                    .foregroundColor(trailingColor)
            }
        )
    }
}

