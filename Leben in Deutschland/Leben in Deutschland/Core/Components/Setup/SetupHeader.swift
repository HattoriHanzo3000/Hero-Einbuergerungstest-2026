//
//  SetupHeader.swift
//  Leben in Deutschland
//
//  Reusable header component for Setup screens
//

import SwiftUI
import UIKit

// MARK: - Setup Header
struct SetupHeader: View {
    let title: String
    let onDismiss: () -> Void
    
    private var cornerRadius: CGFloat { MainScreenConstants.adaptiveValue(28) }
    private var horizontalPadding: CGFloat { MainScreenConstants.adaptiveValue(20) }
    private var verticalPadding: CGFloat { MainScreenConstants.adaptiveValue(18) }
    private var topInset: CGFloat { MainScreenConstants.adaptiveValue(12) }
    private var controlSize: CGFloat { MainScreenConstants.adaptiveValue(36) }
    private var controlPadding: CGFloat { MainScreenConstants.adaptiveValue(8) }
    private var topSafeArea: CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return 0
        }
        return window.safeAreaInsets.top
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: MainScreenConstants.adaptiveValue(12)) {
            HStack {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    onDismiss()
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .foregroundColor(Color(.systemGray6))
                        .frame(width: controlSize, height: controlSize)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.18))
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
                .accessibilityHint("Dismiss")
                
                Spacer()
            }
            
            Text(title.localized)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundColor(Color(.systemGray6))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .accessibilityAddTraits(.isHeader)
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.accentColor)
                .shadow(color: .black.opacity(0.12),
                        radius: MainScreenConstants.adaptiveValue(12),
                        x: 0,
                        y: MainScreenConstants.adaptiveValue(6))
        )
        .padding(.horizontal)
        .padding(.top, topSafeArea + topInset)
    }
}

// MARK: - Preview
#Preview {
    SetupHeader(title: "federal_states_title", onDismiss: {})
        .environmentObject(StateManager())
        .environmentObject(LanguageManager())
}

