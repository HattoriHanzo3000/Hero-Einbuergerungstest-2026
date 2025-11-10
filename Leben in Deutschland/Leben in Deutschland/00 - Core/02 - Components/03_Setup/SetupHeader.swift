//
//  SetupHeader.swift
//  Leben in Deutschland
//
//  Reusable header component for Setup screens
//

import SwiftUI

// MARK: - Setup Header
struct SetupHeader: View {
    enum PresentationStyle {
        case modal
        case navigation
    }
    
    let title: String
    let onDismiss: () -> Void
    var presentationStyle: PresentationStyle
    
    private var cornerRadius: CGFloat { MainScreenConstants.adaptiveValue(28) }
    private var horizontalPadding: CGFloat { MainScreenConstants.adaptiveValue(20) }
    private var verticalPadding: CGFloat { MainScreenConstants.adaptiveValue(18) }
    private var topInset: CGFloat { MainScreenConstants.adaptiveValue(18) }
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private var controlSize: CGFloat {
        switch dynamicTypeSize {
        case .xSmall, .small, .medium:
            return MainScreenConstants.adaptiveValue(36)
        case .large:
            return MainScreenConstants.adaptiveValue(38)
        case .xLarge:
            return MainScreenConstants.adaptiveValue(40)
        case .xxLarge, .xxxLarge:
            return MainScreenConstants.adaptiveValue(42)
        default:
            return MainScreenConstants.adaptiveValue(44)
        }
    }
    private var controlPadding: CGFloat { controlSize * 0.25 }
    
    init(
        title: String,
        presentationStyle: PresentationStyle = .modal,
        onDismiss: @escaping () -> Void
    ) {
        self.title = title
        self.presentationStyle = presentationStyle
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: MainScreenConstants.adaptiveValue(12)) {
            HStack {
                headerButton
                
                Spacer()
            }
            
            Text(title.localized)
                .font(.system(.title, design: .rounded).weight(.bold))
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
        .padding(.top, topInset)
    }
}

private extension SetupHeader {
    @ViewBuilder
    var headerButton: some View {
        switch presentationStyle {
        case .modal:
            AdaptiveIconButton.dismissButton {
                onDismiss()
            }
        case .navigation:
            AdaptiveIconButton.backButton {
                onDismiss()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SetupHeader(title: "federal_states_title", onDismiss: {})
        .environmentObject(StateManager())
        .environmentObject(LanguageManager())
}

