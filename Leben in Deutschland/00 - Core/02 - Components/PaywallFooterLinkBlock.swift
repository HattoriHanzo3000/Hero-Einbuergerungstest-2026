//
//  PaywallFooterLinkBlock.swift
//  Leben in Deutschland
//
//  Footnote caption + action link used in paywall footers.
//

import SwiftUI

struct PaywallFooterLinkBlock: View {
    let caption: String
    let actionTitle: String
    var isActionDisabled: Bool = false
    var horizontalPadding: CGFloat = 24
    let action: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            Text(caption)
                .font(.system(.footnote, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))
                .multilineTextAlignment(.center)

            Button(actionTitle, action: action)
                .font(.system(.caption2, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
                .disabled(isActionDisabled)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, horizontalPadding)
        .fontDesign(.default)
    }
}
