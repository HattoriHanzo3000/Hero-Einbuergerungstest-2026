//
//  PremiumButton.swift
//  Leben in Deutschland
//
//  Reusable premium button. Shows "PREMIUM" badge in a rounded rect.
//  Use in headers and anywhere the user can open the paywall.
//  Tappable area meets 44pt minimum.
//

import SwiftUI

// MARK: - Premium Button
/// Premium badge that opens paywall. Reusable across the app.
struct PremiumButton: View {
    let action: () -> Void

    /// Foreground color (e.g. .white on dark headers, .primary on light).
    var color: Color = .white

    @Environment(\.layoutMetrics) private var layoutMetrics

    var body: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            action()
        }) {
            Text("settings_premium_title".localized.uppercased())
                .font(.system(.footnote, weight: .regular).width(.expanded))
                .foregroundColor(color)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, layoutMetrics.adaptive(8))
                .padding(.vertical, layoutMetrics.adaptive(4))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(color, lineWidth: 0.6)
                )
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("premium_accessibility_label".localized)
        .accessibilityHint("premium_accessibility_hint".localized)
    }
}

// MARK: - Preview
#Preview("Premium button") {
    PremiumButton(action: {}, color: .white)
        .padding()
        .background(Color.blue)
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
