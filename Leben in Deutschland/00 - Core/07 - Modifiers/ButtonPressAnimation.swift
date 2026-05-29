//
//  ButtonPressAnimation.swift
//  Leben in Deutschland
//
//  Reusable button press animation modifier
//  Provides consistent press behavior across all app buttons
//

import SwiftUI

// MARK: - Button Press Animation Modifier
struct ButtonPressAnimation: ViewModifier {
    @Binding var isPressed: Bool
    let releaseDelay: Double
    
    // MARK: - Constants
    private static let animationDuration: Double = 0.1
    static let defaultReleaseDelay: Double = 0.05
    
    init(isPressed: Binding<Bool>, releaseDelay: Double = Self.defaultReleaseDelay) {
        self._isPressed = isPressed
        self.releaseDelay = releaseDelay
    }
    
    func body(content: Content) -> some View {
        content
            .animation(.easeInOut(duration: Self.animationDuration), value: isPressed)
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
    /// Applies consistent button press animation modifier
    /// 
    /// This modifier tracks button press state and provides smooth animation feedback.
    /// It uses `onLongPressGesture` with zero minimum duration to detect all press events,
    /// and includes a brief delay after release for better visual feedback.
    /// 
    /// Typically used in combination with `.scaleEffect(isPressed ? 0.98 : 1.0)` to provide
    /// visual feedback when the button is pressed.
    /// 
    /// - Parameters:
    ///   - isPressed: Binding to track press state (should be a `@State` variable in the view)
    ///   - releaseDelay: Delay in seconds before releasing press state after touch ends (default: 0.05)
    /// 
    /// - Example:
    /// ```swift
    /// @State private var isPressed = false
    /// 
    /// Button("Tap Me") { }
    ///     .scaleEffect(isPressed ? 0.98 : 1.0)
    ///     .buttonPressAnimation(isPressed: $isPressed)
    /// ```
    func buttonPressAnimation(isPressed: Binding<Bool>, releaseDelay: Double = ButtonPressAnimation.defaultReleaseDelay) -> some View {
        self.modifier(ButtonPressAnimation(isPressed: isPressed, releaseDelay: releaseDelay))
    }
}

// MARK: - Preview
#Preview {
    struct PreviewButton: View {
        @State private var isPressed = false
        
        var body: some View {
            Button("Press Me") {
                HapticManager.shared.lightImpact()
            }
            .font(.title3.bold())
            .foregroundColor(.white)
            .frame(width: 200, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .buttonPressAnimation(isPressed: $isPressed)
            .padding()
        }
    }
    
    return PreviewButton()
}