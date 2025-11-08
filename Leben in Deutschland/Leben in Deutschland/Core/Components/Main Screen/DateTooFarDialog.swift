//
//  DateTooFarDialog.swift
//  Leben in Deutschland
//
//  Warning dialog when user selects a test date too far in the future
//

import SwiftUI

// MARK: - Date Too Far Dialog
struct DateTooFarDialog: View {
    let isPresented: Bool
    let onDismiss: () -> Void
    
    @State private var isOKPressed = false
    
    var body: some View {
        ZStack {
            if isPresented {
                // Background overlay
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        onDismiss()
                    }
                    .accessibilityHidden(true)
            
                // Dialog card
                VStack(spacing: 16) {
                    Text("date_too_far_title".localized)
                        .font(.system(.headline, design: .rounded).weight(.semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .padding(.top, 16)
                    
                    Text("date_too_far_message".localized)
                        .font(.system(.body, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                    
                    // OK Button
                    Text("ok_button".localized)
                        .font(.system(.callout, design: .rounded).weight(.medium))
                        .foregroundColor(Color(.systemGray6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.accentColor)
                        )
                        .scaleEffect(isOKPressed ? 0.97 : 1.0)
                        .animation(.easeInOut(duration: 0.08), value: isOKPressed)
                        .onLongPressGesture(
                            minimumDuration: 0,
                            maximumDistance: .infinity,
                            pressing: { pressing in
                                isOKPressed = pressing
                            },
                            perform: {
                                onDismiss()
                            }
                        )
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
    DateTooFarDialog(
        isPresented: true,
        onDismiss: {
            print("Dialog dismissed")
        }
    )
}

