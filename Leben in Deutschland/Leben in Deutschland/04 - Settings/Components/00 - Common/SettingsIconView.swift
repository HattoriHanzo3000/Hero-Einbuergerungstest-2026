import SwiftUI

/// Shared icon styling for Settings rows.
struct SettingsIconView: View {
    let systemName: String
    let tint: Color

    var body: some View {
        ZStack {
            RoundedRectangle(
                cornerRadius: SettingsDesignTokens.Layout.iconCornerRadius,
                style: .continuous
            )
            .fill(tint.opacity(0.2))

            RoundedRectangle(
                cornerRadius: SettingsDesignTokens.Layout.iconCornerRadius,
                style: .continuous
            )
            .stroke(tint.opacity(0.35), lineWidth: SettingsDesignTokens.Layout.iconStrokeWidth)

            Image(systemName: systemName)
                .font(.system(size: SettingsDesignTokens.Icon.symbolSize, weight: .semibold))
                .foregroundStyle(tint)
        }
        .frame(
            width: SettingsDesignTokens.Icon.containerSize,
            height: SettingsDesignTokens.Icon.containerSize
        )
        .accessibilityHidden(true)
    }
}

#Preview("Settings Icon") {
    SettingsIconView(systemName: "info.circle.fill", tint: .blue)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .previewLayout(.sizeThatFits)
}

