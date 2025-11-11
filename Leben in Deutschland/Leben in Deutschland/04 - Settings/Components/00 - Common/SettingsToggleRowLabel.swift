import SwiftUI

/// Standardized label for toggle rows within Settings.
struct SettingsToggleRowLabel: View {
    let title: String
    let iconSystemName: String
    let tint: Color
    let subtitle: String?

    init(
        title: String,
        iconSystemName: String,
        tint: Color,
        subtitle: String? = nil
    ) {
        self.title = title
        self.iconSystemName = iconSystemName
        self.tint = tint
        self.subtitle = subtitle
    }

    var body: some View {
        HStack(alignment: .center, spacing: SettingsDesignTokens.Layout.rowSpacing) {
            SettingsIconView(systemName: iconSystemName, tint: tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, SettingsDesignTokens.Layout.rowVerticalPadding)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

#Preview("Settings Toggle Label") {
    SettingsToggleRowLabel(
        title: "Sound effects",
        iconSystemName: "speaker.wave.2.fill",
        tint: .green,
        subtitle: "Plays helpful cues during quizzes."
    )
    .padding()
    .previewLayout(.sizeThatFits)
}

