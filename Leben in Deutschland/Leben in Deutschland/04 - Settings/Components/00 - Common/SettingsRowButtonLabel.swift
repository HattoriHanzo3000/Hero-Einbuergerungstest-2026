import SwiftUI

/// Standard row layout for tappable Settings actions.
struct SettingsRowButtonLabel: View {
    let title: String
    let iconSystemName: String
    let tint: Color
    let showsChevron: Bool

    init(title: String, iconSystemName: String, tint: Color, showsChevron: Bool = true) {
        self.title = title
        self.iconSystemName = iconSystemName
        self.tint = tint
        self.showsChevron = showsChevron
    }

    var body: some View {
        HStack(spacing: SettingsDesignTokens.Layout.rowSpacing) {
            SettingsIconView(systemName: iconSystemName, tint: tint)

            Text(title)
                .font(.body)
                .foregroundStyle(.primary)

            Spacer(minLength: 0)

            trailingChevron(showing: showsChevron)
        }
        .padding(.vertical, SettingsDesignTokens.Layout.rowVerticalPadding)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private func trailingChevron(showing: Bool) -> some View {
        if showing {
            Image(systemName: "chevron.forward")
                .font(
                    .system(
                        size: SettingsDesignTokens.Icon.trailingChevronSize,
                        weight: SettingsDesignTokens.Icon.trailingChevronWeight
                    )
                )
                .foregroundStyle(SettingsDesignTokens.Palette.trailingValue)
                .accessibilityHidden(true)
        }
    }
}

#Preview("Settings Row Button") {
    SettingsRowButtonLabel(
        title: "Check for Updates",
        iconSystemName: "arrow.down.circle.fill",
        tint: .blue
    )
    .padding()
    .previewLayout(.sizeThatFits)
}

