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
    
    var body: some View {
        GeometryReader { geometry in
            let sidePadding = MainScreenConstants.getFooterSidePadding()
            
            VStack(spacing: 0) {
                // Footer content - four icons with equal spacing, vertically centered
                HStack(spacing: 0) {
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
                .frame(maxHeight: .infinity, alignment: .center)
                .padding(.horizontal, sidePadding)
            }
        }
        .frame(height: MainScreenConstants.getFooterHeight())
        .background(
            RoundedRectangle(cornerRadius: 0, style: .continuous)
                .fill(Color("AppOrange"))
                .clipShape(
                    RoundedCorner(radius: 35, corners: [.topLeft, .topRight])
                )
                .ignoresSafeArea(.all, edges: .bottom)
        )
    }
}

// MARK: - Footer Button Content
struct FooterButtonContent: View {
    let icon: String
    @Binding var isPressed: Bool
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .fontWeight(.heavy)
                .foregroundColor(Color(.systemGray6))
        }
        .contentShape(Rectangle())
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.08), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {
            HapticManager.shared.lightImpact()
            action()
        })
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Date Button Content
struct DateButtonContent: View {
    @Binding var savedTestDate: Date?
    @Binding var isPressed: Bool
    let action: () -> Void
    
    var body: some View {
        Group {
            if let testDate = savedTestDate {
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let testDateStart = calendar.startOfDay(for: testDate)
                let daysUntilTest = calendar.dateComponents([.day], from: today, to: testDateStart).day ?? 0
                
                if daysUntilTest > 0 {
                    // Dynamic rounded rectangle with days count (supports up to year 9999 ≈ 2.9M days)
                    let digitCount = String(daysUntilTest).count
                    let width: CGFloat = CGFloat(34 + (digitCount - 1) * 10) + 8  // +8 for padding
                    
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray6), lineWidth: 4)
                        .frame(width: width, height: 34)
                        .overlay(
                            Text("\(daysUntilTest)")
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .foregroundColor(Color(.systemGray6))
                                .padding(.horizontal, 4)
                        )
                        .accessibilityLabel("Test Date")
                        .accessibilityValue("\(daysUntilTest) days until test")
                        .accessibilityHint("Tap to change test date")
                } else {
                    // Show calendar icon if test date is today or past
                    FooterButtonContent(
                        icon: "calendar",
                        isPressed: $isPressed,
                        action: action
                    )
                    .accessibilityLabel("Test Date")
                    .accessibilityValue("Test is today or past")
                    .accessibilityHint("Tap to change test date")
                }
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
        .contentShape(Rectangle())
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.08), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {
            HapticManager.shared.lightImpact()
            action()
        })
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
