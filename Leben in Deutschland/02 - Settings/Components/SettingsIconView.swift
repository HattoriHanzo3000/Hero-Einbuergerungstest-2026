import SwiftUI

/// Shared icon styling for Settings rows.
struct SettingsIconView: View {
    let systemName: String
    let tint: Color

    var body: some View {
        Image(systemName: systemName)
            .font(.body)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .frame(
                width: SettingsDesignTokens.Icon.containerSize,
                height: SettingsDesignTokens.Icon.containerSize
            )
            .background(
                RoundedRectangle(
                    cornerRadius: SettingsDesignTokens.Layout.iconCornerRadius,
                    style: .continuous
                )
                .fill(tint)
            )
        .frame(
            width: SettingsDesignTokens.Icon.containerSize,
            height: SettingsDesignTokens.Icon.containerSize
        )
        .accessibilityHidden(true)
    }
}

#Preview("Settings Icon", traits: .sizeThatFitsLayout) {
    SettingsIconView(systemName: "info.circle.fill", tint: .blue)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
}

