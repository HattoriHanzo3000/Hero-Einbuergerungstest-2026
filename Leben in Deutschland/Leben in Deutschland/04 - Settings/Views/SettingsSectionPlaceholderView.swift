import SwiftUI

/// Reusable placeholder that will be removed once the concrete section views land.
struct SettingsSectionPlaceholderView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Settings Placeholder Section") {
    SettingsSectionPlaceholderView(
        title: "Example Section",
        message: "Concrete content will replace this placeholder."
    )
    .padding()
}

