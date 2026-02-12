import SwiftUI

/// Trailing value label with optional symbol used across Settings rows.
struct SettingsTrailingValueLabel: View {
    let text: String
    let systemImage: String

    init(text: String, systemImage: String) {
        self.text = text
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.callout.weight(.medium))
                .foregroundStyle(SettingsDesignTokens.Palette.trailingValue)
            Image(systemName: systemImage)
                .font(
                    .system(
                        size: SettingsDesignTokens.Icon.trailingChevronSize,
                        weight: SettingsDesignTokens.Icon.trailingChevronWeight
                    )
                )
                .foregroundStyle(SettingsDesignTokens.Palette.trailingValue)
                .accessibilityHidden(true)
        }
        .contentShape(Rectangle())
    }
}

#Preview("Trailing Value Label", traits: .sizeThatFitsLayout) {
    SettingsTrailingValueLabel(
        text: "System",
        systemImage: "chevron.up.chevron.down"
    )
    .padding()
}

