import SwiftUI

// MARK: - Main Header Content
struct MainHeaderContent: View {
    @EnvironmentObject var stateManager: StateManager
    @Binding var showDialog: Bool
    let onStateButtonTapped: () -> Void
    @State private var isStateButtonPressed = false
    
    // Standard horizontal padding for consistency
    private let standardPadding: CGFloat = 16
    // Fixed header height to prevent stretching
    private let headerHeight: CGFloat = 180
    
    var body: some View {
        ZStack {
            // Background that extends into safe area
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.accentColor)
                .ignoresSafeArea(edges: .top)
            
            // Content
            VStack(spacing: 12) {
                // Row 1: Federal state (centered, single line)
                if let selectedState = stateManager.selectedState {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        onStateButtonTapped()
                    }) {
                        Text(getLocalizedStateName(selectedState))
                            .font(.title2.bold())
                            .fontDesign(.rounded)
                            .foregroundColor(Color(.systemGray6))
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .minimumScaleFactor(0.8)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                    .scaleEffect(isStateButtonPressed ? 0.97 : 1.0)
                    .animation(.easeInOut(duration: 0.08), value: isStateButtonPressed)
                    .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                        isStateButtonPressed = pressing
                    }, perform: {})
                    .accessibilityLabel("Federal State")
                    .accessibilityValue(getLocalizedStateName(selectedState))
                    .accessibilityHint("Tap to change federal state")
                    .accessibilityAddTraits(.isButton)
                }
                
                // Row 2: Mascot with bubble (dynamic height)
                MainMascotView(
                    messageKey: "eagle_desc_chick",
                    showDialog: $showDialog
                )
                .frame(minHeight: 120) // Minimum height to match mascot size, but can grow
            }
            .padding(standardPadding) // Same padding on all 4 sides
            .frame(height: headerHeight - (standardPadding * 2)) // Fixed height minus padding on top and bottom
        }
        .frame(height: headerHeight)
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
    
    private func getLocalizedStateName(_ stateName: String) -> String {
        return stateName.localized
    }
}

// MARK: - Preview
#Preview {
    MainHeaderContent(
        showDialog: .constant(true),
        onStateButtonTapped: {
            print("State button tapped")
        }
    )
    .environmentObject(StateManager())
}
