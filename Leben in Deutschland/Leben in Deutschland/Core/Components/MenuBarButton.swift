//
//  MenuBarButton.swift
//  Leben in Deutschland
//
//  Reusable circular menu bar button with glass effect, stroke, and shadow
//

import SwiftUI

// MARK: - Menu Bar Button
struct MenuBarButton: View {
    let icon: String
    let size: CGFloat
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        icon: String,
        size: CGFloat = 40,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button {
            HapticManager.shared.lightImpact()
            action()
        } label: {
            ZStack {
                // Base background
                Circle()
                    .fill(Color("MainButton"))
                    .frame(width: size, height: size)
                
                // Glass effect - sharp highlight
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: .clear, location: 0.60),
                                .init(color: .white.opacity(0.6), location: 0.63),
                                .init(color: .white.opacity(0.6), location: 0.68),
                                .init(color: .clear, location: 0.70)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                
                // Stroke
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    .frame(width: size, height: size)
                
                // Icon
                Image(systemName: icon)
                    .font(.system(size: size * 0.45, weight: .semibold))
                    .foregroundColor(Color("MainButtonText"))
            }
            .background(
                // Shadow layer
                Circle()
                    .fill(Color(.systemGray))
                    .frame(width: size, height: isPressed ? size + 3 : size + 8)
                    .opacity(0.3)
                    .offset(y: isPressed ? 3 : 4)
            )
            .offset(y: isPressed ? 2 : 0)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .contentShape(Circle())
        }
        .buttonStyle(NoEffectButtonStyle())
        .buttonPressAnimation(isPressed: $isPressed)
    }
}

// MARK: - Preview
#Preview {
    HStack(spacing: 20) {
        MenuBarButton(icon: "globe", size: 40) {
            print("Globe tapped")
        }
        
        MenuBarButton(icon: "gearshape.fill", size: 40) {
            print("Settings tapped")
        }
        
        MenuBarButton(icon: "crown.fill", size: 40) {
            print("Premium tapped")
        }
        
        MenuBarButton(icon: "star.fill", size: 50) {
            print("Large button tapped")
        }
    }
    .padding()
    .background(Color("Fill"))
}

