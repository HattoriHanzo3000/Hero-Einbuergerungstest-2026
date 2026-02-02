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
            Spacer()
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
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

