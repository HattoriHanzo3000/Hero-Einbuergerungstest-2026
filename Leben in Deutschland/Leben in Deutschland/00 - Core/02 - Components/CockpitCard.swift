import SwiftUI

/// Shared cockpit section container styled to match B2 card chrome.
struct CockpitCard<Content: View>: View {
    let titleIcon: String
    let title: String
    let subtitle: String?
    private let titleTrailing: AnyView?
    @ViewBuilder let content: Content
    @Environment(\.colorScheme) private var colorScheme

    init(
        titleIcon: String,
        title: String,
        subtitle: String? = nil,
        titleTrailing: AnyView? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.titleIcon = titleIcon
        self.title = title
        self.subtitle = subtitle
        self.titleTrailing = titleTrailing
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: titleIcon)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(
                        LiquidGlassGradient.blue.screenBackground,
                        in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                    )

                Text(title)
                    .font(.system(.title3, weight: .regular))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Spacer(minLength: 8)

                if let titleTrailing {
                    titleTrailing
                }
            }

            if let subtitle {
                Text(subtitle)
                    .font(.system(.subheadline, weight: .regular).width(.condensed))
                    .foregroundColor(.secondary)
            }

            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.22),
                            Color.white.opacity(0.10)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(.secondarySystemGroupedBackground))
                        if colorScheme == .dark {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color("AppBlue").opacity(0.18))
                        }
                    }
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            .white.opacity(0.35),
                            .white.opacity(0.08)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.6
                )
        )
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}
