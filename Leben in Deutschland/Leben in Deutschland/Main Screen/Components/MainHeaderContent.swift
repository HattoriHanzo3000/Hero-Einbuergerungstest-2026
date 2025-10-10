import SwiftUI

// MARK: - Main Header Content
struct MainHeaderContent: View {
    @EnvironmentObject var stateManager: StateManager
    @Binding var showDialog: Bool
    let onStateButtonTapped: () -> Void
    @State private var isStateButtonPressed = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Federal state button - top part (25% of header)
            GeometryReader { geometry in
                let sidePadding = MainScreenConstants.getHeaderSidePadding()
                
                VStack(spacing: 0) {
                    Spacer() // Push content to bottom
                    
                    // Header content - federal state button in center
                    HStack {
                        Spacer()
                        
                        // Federal state button in the center
                        if let selectedState = stateManager.selectedState {
                            ZStack {
                                Text(getLocalizedStateName(selectedState))
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(.systemGray6))
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: true, vertical: true)
                                    .padding(.horizontal, 5)
                                    .frame(maxWidth: MainScreenConstants.federalStateButtonMaxWidth)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.clear)
                            )
                            .scaleEffect(isStateButtonPressed ? 0.97 : 1.0)
                            .animation(.easeInOut(duration: 0.08), value: isStateButtonPressed)
                            .contentShape(Rectangle())
                            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                                isStateButtonPressed = pressing
                            }, perform: {
                                HapticManager.shared.lightImpact()
                                onStateButtonTapped()
                            })
                            .accessibilityLabel("Federal State")
                            .accessibilityValue(getLocalizedStateName(selectedState))
                            .accessibilityHint("Tap to change federal state")
                            .accessibilityAddTraits(.isButton)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, sidePadding)
                    .padding(.bottom, 10)
                }
            }
            .frame(height: MainScreenConstants.getHeaderHeight() * 0.25) // 25% of header height for federal state
            
            // Mascot section - bottom part of header (75% of header)
            MainMascotView(
                messageKey: "eagle_desc_chick", // Temporary message, will be dynamic later
                showDialog: $showDialog
            )
            .frame(height: MainScreenConstants.getHeaderHeight() * 0.75) // 75% of header height for mascot
        }
        .background(
            RoundedRectangle(cornerRadius: 0, style: .continuous)
                .fill(Color("Fill"))
                .clipShape(
                    RoundedCorner(radius: 35, corners: [.bottomLeft, .bottomRight])
                )
                .ignoresSafeArea(.all, edges: .top)
        )
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
