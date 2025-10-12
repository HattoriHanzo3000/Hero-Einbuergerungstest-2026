//
//  UpdateAlertDialog.swift
//  Leben in Deutschland
//
//  Update check alert dialog with custom design
//

import SwiftUI

// MARK: - Update Alert Dialog
struct UpdateAlertDialog: View {
    let isPresented: Bool
    let title: String
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            if isPresented {
                // Dimmed background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        onDismiss()
                    }
                    .accessibilityHidden(true)
                
                // Alert dialog
                VStack(spacing: 16) {
                    // Title
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.top, 16)
                        .accessibilityAddTraits(.isHeader)
                    
                    // Message
                    Text(message)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                    
                    // OK Button
                    Button(action: onDismiss) {
                        Text("ok".localized)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("Fill"))
                            )
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .accessibilityLabel("OK")
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                        .shadow(color: .black.opacity(0.6), radius: 10, x: 0, y: 6)
                )
                .padding(.horizontal, 32)
                .transition(.scale.combined(with: .opacity))
                .zIndex(20)
                .accessibilityElement(children: .contain)
                .accessibilityAddTraits(.isModal)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPresented)
    }
}

// MARK: - Preview
#Preview {
    UpdateAlertDialog(
        isPresented: true,
        title: "You're up to date",
        message: "You already have the latest version installed.",
        onDismiss: {}
    )
}

