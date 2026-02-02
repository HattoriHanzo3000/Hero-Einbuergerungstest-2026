import SwiftUI

/// Shared icon styling for Settings rows.
struct SettingsIconView: View {
    let systemName: String
    let tint: Color

    var body: some View {
        Image(systemName: systemName)
            .symbolRenderingMode(.palette)
            .foregroundStyle(tint.opacity(0.18), tint)
            .font(.system(size: SettingsDesignTokens.Icon.size, weight: .semibold))
            .accessibilityHidden(true)
    }
}

#Preview("Settings Icon") {
    SettingsIconView(systemName: "info.circle.fill", tint: .blue)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .previewLayout(.sizeThatFits)
}

