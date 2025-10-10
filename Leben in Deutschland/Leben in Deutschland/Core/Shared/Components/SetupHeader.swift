//
//  SetupHeader.swift
//  Leben in Deutschland
//
//  Reusable header component for Setup screens
//

import SwiftUI

// MARK: - Setup Header
struct SetupHeader: View {
    let title: String
    let onDismiss: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let sidePadding = screenWidth * 0.05
            
            ZStack {
                // Back button
                HStack {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        onDismiss()
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(.systemGray6))
                    }
                    .padding(.leading, sidePadding)
                    .accessibilityLabel("Close")
                    .accessibilityHint("Dismiss")
                    
                    Spacer()
                }
                
                // Title
                Text(title.localized)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color(.systemGray6))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .padding(.horizontal, sidePadding + 44)
                    .accessibilityAddTraits(.isHeader)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: UIScreen.main.bounds.height * 0.1)
        .background(
            RoundedRectangle(cornerRadius: 0, style: .continuous)
                .fill(Color("Fill"))
                .clipShape(
                    RoundedCorner(radius: 35, corners: [.bottomLeft, .bottomRight])
                )
                .ignoresSafeArea(.all, edges: .top)
        )
    }
}

// MARK: - Preview
#Preview {
    SetupHeader(title: "federal_states_title", onDismiss: {})
}

