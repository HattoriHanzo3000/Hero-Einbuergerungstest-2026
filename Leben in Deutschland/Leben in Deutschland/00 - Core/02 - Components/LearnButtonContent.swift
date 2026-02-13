//
//  LearnButtonContent.swift
//  Leben in Deutschland
//
//  Reusable learn option button: icon in rounded rect, title, subtitle, chevron.
//  Used in HomeLearnOptionsSection.
//

import SwiftUI

// MARK: - Learn Button Content
struct LearnButtonContent: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    @Environment(\.layoutMetrics) private var layoutMetrics

    var body: some View {
        HStack(spacing: layoutMetrics.adaptive(16)) {
            Image(systemName: icon)
                .font(.system(size: layoutMetrics.adaptive(24), weight: .semibold))
                .foregroundColor(.white)
                .frame(width: layoutMetrics.adaptive(52), height: layoutMetrics.adaptive(52))
                .background(
                    RoundedRectangle(cornerRadius: layoutMetrics.adaptive(16), style: .continuous)
                        .fill(color)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title.localized)
                    .font(.system(.headline, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                Text(subtitle.localized)
                    .font(.system(.subheadline, weight: .light).width(.compressed))
                    .foregroundColor(.primary.opacity(0.7))
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: layoutMetrics.adaptive(14), weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(layoutMetrics.adaptive(18))
        .background(
            RoundedRectangle(cornerRadius: layoutMetrics.adaptive(20), style: .continuous)
                .fill(Color(.tertiarySystemBackground).opacity(0.9))
        )
        .contentShape(Rectangle())
    }
}
