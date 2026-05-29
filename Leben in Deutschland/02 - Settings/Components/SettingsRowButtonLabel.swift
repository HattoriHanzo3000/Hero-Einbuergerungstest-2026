import SwiftUI

/// Standard row layout for tappable Settings actions.
struct SettingsRowButtonLabel: View {
    let title: String
    let subtitle: String?
    let iconSystemName: String?
    let tint: Color
    let trailingText: String?
    let trailingTextColor: Color
    let showsBadge: Bool
    let showsChevron: Bool

    init(
        title: String,
        subtitle: String? = nil,
        iconSystemName: String? = nil,
        tint: Color,
        trailingText: String? = nil,
        trailingTextColor: Color = SettingsDesignTokens.Palette.trailingValue,
        showsBadge: Bool = false,
        showsChevron: Bool = true
    ) {
        self.title = title
        self.subtitle = subtitle
        self.iconSystemName = iconSystemName
        self.tint = tint
        self.trailingText = trailingText
        self.trailingTextColor = trailingTextColor
        self.showsBadge = showsBadge
        self.showsChevron = showsChevron
    }

    var body: some View {
        HStack(spacing: SettingsDesignTokens.Layout.rowSpacing) {
            if let iconSystemName {
                SettingsIconView(systemName: iconSystemName, tint: tint)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                if let subtitle, subtitle.isEmpty == false {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)

            if let trailingText, trailingText.isEmpty == false {
                Text(trailingText)
                    .font(.callout)
                    .foregroundStyle(trailingTextColor)
            }

            if showsBadge {
                Circle()
                    .fill(SettingsDesignTokens.Palette.notification)
                    .frame(width: SettingsDesignTokens.Icon.badgeSize, height: SettingsDesignTokens.Icon.badgeSize)
                    .accessibilityLabel(Text("settings_badge_new".localized))
            }

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

#Preview("Settings Row Button", traits: .sizeThatFitsLayout) {
    SettingsRowButtonLabel(
        title: "Check for Updates",
        iconSystemName: "arrow.down.circle.fill",
        tint: .blue
    )
    .padding()
}

