//
//  StateChangeConfirmationDialog.swift
//  Leben in Deutschland
//
//  Confirmation dialog for state change with progress warning
//

import SwiftUI

// MARK: - State Change Confirmation Dialog
struct StateChangeConfirmationDialog: View {
    let isPresented: Bool
    let onCancel: () -> Void
    let onConfirm: () -> Void
    
    var body: some View {
        ZStack {
            if isPresented {
                // Dimmed background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        onCancel()
                    }
                    .accessibilityHidden(true)
                
                // Confirmation dialog
                VStack(spacing: 16) {
                    // Title
                    Text("change_state_confirmation_title".localized)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .padding(.top, 16)
                        .accessibilityAddTraits(.isHeader)
                    
                    // Message
                    Text("change_state_confirmation_message".localized)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                    
                    // Buttons
                    HStack(spacing: 12) {
                        // Cancel button
                        Button(action: onCancel) {
                            Text("change_state_confirmation_cancel".localized)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("Fill"))
                                )
                        }
                        .accessibilityLabel("Cancel")
                        .accessibilityHint("Keep current state without changes")
                        
                        // Confirm button
                        Button(action: onConfirm) {
                            Text("change_state_confirmation_confirm".localized)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red)
                                )
                        }
                        .accessibilityLabel("Confirm change")
                        .accessibilityHint("Change state and clear all progress")
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
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
    StateChangeConfirmationDialog(
        isPresented: true,
        onCancel: {},
        onConfirm: {}
    )
}
