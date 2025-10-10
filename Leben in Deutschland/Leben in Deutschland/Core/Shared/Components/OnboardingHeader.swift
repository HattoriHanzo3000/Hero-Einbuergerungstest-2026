import SwiftUI

// MARK: - Onboarding Header
struct OnboardingHeader: View {
    let currentStep: Int
    let totalSteps: Int
    let showBackButton: Bool
    let backAction: (() -> Void)?
    
    var body: some View {
        GeometryReader { geometry in
            let sidePadding = OnboardingConstants.getSidePadding()
            
            VStack(spacing: 0) {
                Spacer() // Push progress bar to bottom
                
                HStack {
                    if showBackButton {
                        // Back button
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            backAction?()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGray6))
                        }
                        .padding(.leading, sidePadding)
                        .padding(.trailing, 10)
                    } else {
                        // Invisible placeholder for consistent spacing
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0))
                            .padding(.leading, sidePadding)
                            .padding(.trailing, 10)
                    }
                    
                    // Progress bar
                    ProgressView(value: Double(currentStep), total: Double(totalSteps))
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(.systemGray6)))
                        .frame(maxWidth: .infinity)
                        .frame(height: 8)
                        .padding(.trailing, sidePadding)
                    
                    Spacer()
                }
                .padding(.bottom, 10)
            }
        }
        .frame(height: OnboardingConstants.getHeaderHeight())
                .background(Color("Fill"))
    }
}
