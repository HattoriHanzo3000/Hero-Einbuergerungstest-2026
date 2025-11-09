//
//  UpdateAlertDialog.swift
//  Leben in Deutschland
//
//  Update check alert dialog with custom design
//

import SwiftUI

// MARK: - Update Alert Variants
struct UpdateLatestDialog: View {
    let isPresented: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        UpdateAlertDialogBase(
            isPresented: isPresented,
            title: "update_latest_title".localized,
            message: "update_latest_message".localized,
            buttonTitle: "ok".localized,
            buttonColor: Color.accentColor,
            buttonTextColor: .white,
            onDismiss: onDismiss
        )
    }
}

struct UpdateAvailableDialog: View {
    let isPresented: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        UpdateAlertDialogBase(
            isPresented: isPresented,
            title: "update_title".localized,
            message: "update_message".localized,
            buttonTitle: "ok".localized,
            buttonColor: Color.accentColor,
            buttonTextColor: .white,
            onDismiss: onDismiss
        )
    }
}

struct UpdateRequiredDialog: View {
    let isPresented: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        UpdateAlertDialogBase(
            isPresented: isPresented,
            title: "update_required_title".localized,
            message: "update_required_message".localized,
            buttonTitle: "ok".localized,
            buttonColor: Color.red,
            buttonTextColor: .white,
            onDismiss: onDismiss
        )
    }
}

// MARK: - Generic Dialog Template
fileprivate struct UpdateAlertDialogBase: View {
    let isPresented: Bool
    let title: String
    let message: String
    let buttonTitle: String
    let buttonColor: Color
    let buttonTextColor: Color
    let onDismiss: () -> Void
    
    @State private var isButtonPressed: Bool = false
    
    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        onDismiss()
                    }
                    .accessibilityHidden(true)
                
                VStack(spacing: 16) {
                    Text(title)
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text(message)
                        .font(.system(.body, design: .rounded))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    Text(buttonTitle)
                        .font(.system(.body, design: .rounded).weight(.semibold))
                        .foregroundColor(buttonTextColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(buttonColor)
                        )
                        .scaleEffect(isButtonPressed ? 0.97 : 1.0)
                        .animation(.easeInOut(duration: 0.08), value: isButtonPressed)
                        .onLongPressGesture(
                            minimumDuration: 0,
                            maximumDistance: .infinity,
                            pressing: { pressing in
                                isButtonPressed = pressing
                            },
                            perform: {
                                onDismiss()
                            }
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        .accessibilityLabel(buttonTitle)
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

