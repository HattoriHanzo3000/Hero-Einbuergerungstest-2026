import SwiftUI

// MARK: - Main Footer Content
struct MainFooterContent: View {
    @Binding var savedTestDate: Date?
    @State private var isGlobeTapped = false
    @State private var isCalendarTapped = false
    @State private var isSettingsTapped = false
    @State private var isPremiumTapped = false
    
    let onLanguageTapped: () -> Void
    let onDateTapped: () -> Void
    let onSettingsTapped: () -> Void
    let onPremiumTapped: () -> Void
    
    // Adaptive spacing
    private var standardPadding: CGFloat { MainScreenConstants.adaptiveValue(16) }
    private var footerHeight: CGFloat { MainScreenConstants.adaptiveValue(96) }
    private var cornerRadius: CGFloat { MainScreenConstants.adaptiveValue(28) }
    private var buttonSpacing: CGFloat { MainScreenConstants.adaptiveValue(12) }
    
    var body: some View {
        ZStack {
            // Background island
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color("AppOrange"))
                .ignoresSafeArea(edges: .bottom)
            
            // Content: 1 row with 4 buttons
            HStack(spacing: buttonSpacing) {
                // Language button (globe icon)
                FooterButtonContent(
                    icon: "globe",
                    isPressed: $isGlobeTapped,
                    action: {
                        onLanguageTapped()
                    }
                )
                .accessibilityLabel("Language")
                .accessibilityHint("Tap to change app language")
                
                // Date button (calendar icon or days counter)
                DateButtonContent(
                    savedTestDate: $savedTestDate,
                    isPressed: $isCalendarTapped,
                    action: {
                        onDateTapped()
                    }
                )
                
                // Settings button (gear icon)
                FooterButtonContent(
                    icon: "gearshape.fill",
                    isPressed: $isSettingsTapped,
                    action: {
                        onSettingsTapped()
                    }
                )
                .accessibilityLabel("Settings")
                .accessibilityHint("Tap to open settings")
                
                // Premium button (crown icon)
                FooterButtonContent(
                    icon: "crown.fill",
                    isPressed: $isPremiumTapped,
                    action: {
                        onPremiumTapped()
                    }
                )
                .accessibilityLabel("Premium")
                .accessibilityHint("Tap to view premium features")
            }
            .padding(standardPadding) // Standard padding on all 4 sides
            .frame(height: footerHeight - (standardPadding * 2)) // Fixed height minus padding
        }
        .frame(height: footerHeight)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

// MARK: - Footer Button Content
struct FooterButtonContent: View {
    let icon: String
    @Binding var isPressed: Bool
    let action: () -> Void
    
    // Standard padding for buttons
    private var standardPadding: CGFloat { MainScreenConstants.adaptiveValue(16) }
    private var cornerRadius: CGFloat { MainScreenConstants.adaptiveValue(24) }
    
    var body: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(.title2, design: .rounded).weight(.semibold))
                .foregroundColor(Color(.systemGray6))
                .frame(maxWidth: .infinity)
                .padding(standardPadding) // Standard padding on all 4 sides
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color(.systemGray6).opacity(0.2))
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.08), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Date Button Content
struct DateButtonContent: View {
    @Binding var savedTestDate: Date?
    @Binding var isPressed: Bool
    let action: () -> Void
    
    // Standard padding for buttons
    private let standardPadding: CGFloat = 16
    
    var body: some View {
        Group {
            if let testDate = savedTestDate {
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let testDateStart = calendar.startOfDay(for: testDate)
                let daysUntilTest = calendar.dateComponents([.day], from: today, to: testDateStart).day ?? 0
                
                FooterButtonContent(
                    icon: "calendar",
                    isPressed: $isPressed,
                    action: action
                )
                .accessibilityLabel("Test Date")
                .accessibilityValue(daysUntilTest > 0 ? "\(daysUntilTest) days until test" : "Test is today or past")
                .accessibilityHint("Tap to change test date")
            } else {
                // Show calendar icon if no test date set
                FooterButtonContent(
                    icon: "calendar",
                    isPressed: $isPressed,
                    action: action
                )
                .accessibilityLabel("Test Date")
                .accessibilityValue("No date set")
                .accessibilityHint("Tap to set test date")
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview {
    MainFooterContent(
        savedTestDate: .constant(Date()),
        onLanguageTapped: { print("Language tapped") },
        onDateTapped: { print("Date tapped") },
        onSettingsTapped: { print("Settings tapped") },
        onPremiumTapped: { print("Premium tapped") }
    )
}
