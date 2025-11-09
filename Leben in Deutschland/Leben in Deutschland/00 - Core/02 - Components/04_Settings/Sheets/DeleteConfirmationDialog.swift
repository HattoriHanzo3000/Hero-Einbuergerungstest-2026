import SwiftUI

// Delete confirmation dialog overlay
struct DeleteConfirmationDialog: View {
    let isPresented: Bool
    let onCancel: () -> Void
    let onConfirm: () -> Void
    
    @State private var isCancelPressed = false
    @State private var isDeletePressed = false
    
    var body: some View {
        ZStack {
            if isPresented {
                // Background overlay
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        onCancel()
                    }
                    .accessibilityHidden(true)
            
            // Dialog card
            VStack(spacing: 16) {
                Text("delete_statistics_warning_title".localized)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                
                Text("delete_statistics_warning_message".localized)
                    .font(.system(.body, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                
                HStack(spacing: 12) {
                    Text("cancel".localized)
                        .font(.system(.body, design: .rounded).weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.accentColor)
                        )
                        .scaleEffect(isCancelPressed ? 0.97 : 1.0)
                        .animation(.easeInOut(duration: 0.08), value: isCancelPressed)
                        .onLongPressGesture(
                            minimumDuration: 0,
                            maximumDistance: .infinity,
                            pressing: { pressing in
                                isCancelPressed = pressing
                            },
                            perform: {
                                HapticManager.shared.lightImpact()
                                onCancel()
                            }
                        )
                    
                    Text("delete_button".localized)
                        .font(.system(.body, design: .rounded).weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red)
                        )
                        .scaleEffect(isDeletePressed ? 0.97 : 1.0)
                        .animation(.easeInOut(duration: 0.08), value: isDeletePressed)
                        .onLongPressGesture(
                            minimumDuration: 0,
                            maximumDistance: .infinity,
                            pressing: { pressing in
                                isDeletePressed = pressing
                            },
                            perform: {
                                HapticManager.shared.heavyImpact()
                                onConfirm()
                            }
                        )
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


