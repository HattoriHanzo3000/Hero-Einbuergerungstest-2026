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
    /// When set, used for icon background instead of solid color (e.g. German flag gradient).
    var iconGradient: LinearGradient? = nil
    /// When set with iconSplitColors, overrides icon background (e.g. gold for German flag book).
    var iconBackgroundColor: Color? = nil
    /// When set, applies gradient to the icon itself (e.g. black-to-red for German flag book pages).
    var iconForegroundGradient: LinearGradient? = nil
    /// When set, splits icon: left half first color, right half second color (sharp divide, no gradient).
    var iconSplitColors: (left: Color, right: Color)? = nil
    /// When set, shows a small pill badge above the title (e.g. "Recommended").
    var badgeText: String? = nil

    @Environment(\.layoutMetrics) private var layoutMetrics

    private var resolvedIconBackground: some ShapeStyle {
        if let bg = iconBackgroundColor {
            return AnyShapeStyle(bg)
        }
        if let gradient = iconGradient {
            return AnyShapeStyle(gradient)
        }
        return AnyShapeStyle(color)
    }

    private var badgePatchView: some View {
        Text(badgeText!.localized)
            .font(.system(.caption2, weight: .semibold).italic())
            .textCase(.uppercase)
            .foregroundColor(.white)
            .padding(.horizontal, layoutMetrics.adaptive(8))
            .padding(.vertical, layoutMetrics.adaptive(5))
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color)
            )
            .overlay(
                ShimmerOverlay(duration: 4)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .blendMode(.plusLighter)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
            .accessibilityLabel(badgeText!.localized)
    }

    var body: some View {
        ZStack(alignment: .top) {
            HStack(spacing: layoutMetrics.adaptive(16)) {
                Group {
                    if let split = iconSplitColors {
                    ZStack(alignment: .leading) {
                        Image(systemName: icon)
                            .font(.system(size: layoutMetrics.adaptive(24), weight: .semibold))
                            .foregroundColor(split.left)
                            .frame(width: layoutMetrics.adaptive(52), height: layoutMetrics.adaptive(52))
                            .mask(
                                Rectangle()
                                    .frame(width: layoutMetrics.adaptive(52) / 2)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            )
                        Image(systemName: icon)
                            .font(.system(size: layoutMetrics.adaptive(24), weight: .semibold))
                            .foregroundColor(split.right)
                            .frame(width: layoutMetrics.adaptive(52), height: layoutMetrics.adaptive(52))
                            .mask(
                                Rectangle()
                                    .frame(width: layoutMetrics.adaptive(52) / 2)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                            )
                    }
                    .frame(width: layoutMetrics.adaptive(52), height: layoutMetrics.adaptive(52))
                } else if let gradient = iconForegroundGradient {
                    Image(systemName: icon)
                        .font(.system(size: layoutMetrics.adaptive(24), weight: .semibold))
                        .foregroundStyle(gradient)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: layoutMetrics.adaptive(24), weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(width: layoutMetrics.adaptive(52), height: layoutMetrics.adaptive(52))
            .background(
                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(16), style: .continuous)
                    .fill(resolvedIconBackground)
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

            if badgeText != nil {
                badgePatchView
                    .offset(y: layoutMetrics.adaptive(-12))
                    .frame(maxWidth: .infinity)
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - German Flag Colors
extension LearnButtonContent {
    /// Gold background for All Questions icon (German flag).
    static var germanFlagGold: Color {
        Color(red: 1, green: 0.8, blue: 0)  // #FFCC00
    }

    /// Book icon split: left page black, right page red (German flag), sharp divide.
    static var germanFlagBookSplit: (left: Color, right: Color) {
        (left: .black, right: Color(red: 0.867, green: 0, blue: 0))  // Red #DD0000
    }
}
