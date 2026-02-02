//
//  ActionIconButton.swift
//  Leben in Deutschland
//
//  Lightweight circular action button with configurable icon and tint.
//

import SwiftUI

struct ActionIconButton: View {
    let systemName: String
    let action: () -> Void
    var size: CGFloat = 44
    var iconSize: CGFloat = 18
    var foregroundColor: Color = Color(.systemGray6)
    var backgroundColor: Color? = nil
    var accessibilityLabel: String
    var accessibilityHint: String? = nil
    
    @State private var isPressed = false
    
    var body: some View {
        Button {
            HapticManager.shared.lightImpact()
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .semibold, design: .rounded))
                .foregroundColor(foregroundColor)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill((backgroundColor ?? foregroundColor.opacity(0.2)))
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.94 : 1.0)
        .animation(.easeInOut(duration: 0.12), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .accessibilityLabel(accessibilityLabel.localized)
        .applyAccessibilityHint(accessibilityHint)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Convenience Factory
extension ActionIconButton {
    static func reset(action: @escaping () -> Void) -> ActionIconButton {
        ActionIconButton(
            systemName: "arrow.counterclockwise",
            action: action,
            accessibilityLabel: "Reset",
            accessibilityHint: "Reset the current question"
        )
    }
    
    static func translation(
        isActive: Bool,
        action: @escaping () -> Void
    ) -> ActionIconButton {
        ActionIconButton(
            systemName: "globe",
            action: action,
            foregroundColor: isActive ? Color("AppOrange") : Color(.systemGray6),
            backgroundColor: Color.white.opacity(isActive ? 0.32 : 0.18),
            accessibilityLabel: "Toggle translation",
            accessibilityHint: "Show translated question text"
        )
    }
    
    static func favorite(
        isActive: Bool = false,
        action: @escaping () -> Void
    ) -> ActionIconButton {
        ActionIconButton(
            systemName: "heart.fill",
            action: action,
            foregroundColor: isActive ? .red : Color(.systemGray6),
            backgroundColor: Color.white.opacity(isActive ? 0.32 : 0.18),
            accessibilityLabel: isActive ? "Remove from Favorites" : "Add to Favorites",
            accessibilityHint: isActive ? "Remove this question from favorites" : "Add this question to favorites"
        )
    }
}

#Preview {
    HStack(spacing: 16) {
        ActionIconButton.reset { }
        ActionIconButton.translation(isActive: true) { }
        ActionIconButton.favorite(isActive: true) { }
    }
    .padding()
    .background(Color.accentColor)
}

