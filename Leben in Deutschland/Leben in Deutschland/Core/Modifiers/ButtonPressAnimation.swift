//
//  ButtonPressAnimation.swift
//  Leben in Deutschland
//
//  Reusable button press animation modifier with 3D effect
//  Provides consistent press behavior across all app buttons
//

import SwiftUI

// MARK: - Button Press Animation Modifier
struct ButtonPressAnimation: ViewModifier {
    @Binding var isPressed: Bool
    let releaseDelay: Double
    
    init(isPressed: Binding<Bool>, releaseDelay: Double = 0.05) {
        self._isPressed = isPressed
        self.releaseDelay = releaseDelay
    }
    
    func body(content: Content) -> some View {
        content
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                if pressing {
                    isPressed = true
                } else {
                    // Brief hold after release for visual feedback
                    DispatchQueue.main.asyncAfter(deadline: .now() + releaseDelay) {
                        isPressed = false
                    }
                }
            }, perform: {})
    }
}

// MARK: - View Extension
extension View {
    /// Applies consistent button press animation with 3D effect
    /// - Parameters:
    ///   - isPressed: Binding to track press state
    ///   - releaseDelay: Delay before releasing press state (default: 0.05)
    func buttonPressAnimation(isPressed: Binding<Bool>, releaseDelay: Double = 0.05) -> some View {
        self.modifier(ButtonPressAnimation(isPressed: isPressed, releaseDelay: releaseDelay))
    }
}

// MARK: - Preview
#Preview {
    struct PreviewButton: View {
        @State private var isPressed = false
        
        var body: some View {
            VStack(spacing: 20) {
                // Example button with press animation
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("MainButton"))
                        .frame(width: 200, height: 60)
                    
                    Text("Press Me")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color("MainButtonText"))
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray))
                        .frame(height: isPressed ? 61 : 64)
                        .opacity(0.3)
                        .offset(y: isPressed ? 1 : 2)
                )
                .offset(y: isPressed ? 1 : 0)
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .buttonPressAnimation(isPressed: $isPressed)
                .onTapGesture {
                    HapticManager.shared.lightImpact()
                }
                
                Text(isPressed ? "Pressed!" : "Not Pressed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
    
    return PreviewButton()
}

