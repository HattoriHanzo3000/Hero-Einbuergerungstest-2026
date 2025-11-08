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
    
    @State private var isCancelPressed = false
    @State private var isConfirmPressed = false
    
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
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .accessibilityAddTraits(.isHeader)
                    
                    // Message
                    Text("change_state_confirmation_message".localized)
                        .font(.system(.body, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    
                    // Buttons
                    HStack(spacing: 12) {
                        Button {
                            HapticManager.shared.lightImpact()
                            onCancel()
                        } label: {
                            Text("cancel".localized)
                                .font(.system(.body, design: .rounded).weight(.semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("Fill"))
                                )
                        }
                        .scaleEffect(isCancelPressed ? 0.97 : 1.0)
                        .animation(.easeInOut(duration: 0.08), value: isCancelPressed)
                        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                            isCancelPressed = pressing
                        }, perform: {
                            HapticManager.shared.lightImpact()
                            onCancel()
                        })
                        
                        Button {
                            HapticManager.shared.heavyImpact()
                            onConfirm()
                        } label: {
                            Text("change_state_confirmation_confirm".localized)
                                .font(.system(.body, design: .rounded).weight(.semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red)
                                )
                        }
                        .scaleEffect(isConfirmPressed ? 0.97 : 1.0)
                        .animation(.easeInOut(duration: 0.08), value: isConfirmPressed)
                        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                            isConfirmPressed = pressing
                        }, perform: {
                            HapticManager.shared.heavyImpact()
                            onConfirm()
                        })
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
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

#Preview("Medium") {
    StateChangeConfirmationDialog(
        isPresented: true,
        onCancel: {},
        onConfirm: {}
    )
    .environment(\.dynamicTypeSize, .medium)
}

#Preview("xxxLarge") {
    StateChangeConfirmationDialog(
        isPresented: true,
        onCancel: {},
        onConfirm: {}
    )
    .environment(\.dynamicTypeSize, .xxxLarge)
}
