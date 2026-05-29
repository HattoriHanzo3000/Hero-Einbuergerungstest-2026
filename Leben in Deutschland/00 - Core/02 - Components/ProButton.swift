//
//  ProButton.swift
//  Leben in Deutschland
//
//  Reusable Pro button/badge components for headers and paywall surfaces.
//

import SwiftUI

// MARK: - Shimmer Overlay (reusable for badges)
struct ShimmerOverlay: View {
    var duration: Double = 4

    @State private var phase: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            LinearGradient(
                colors: [.clear, .white.opacity(0.62), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geo.size.width * 0.5)
            .offset(x: phase * geo.size.width * 1.8 - geo.size.width * 0.5)
        }
        .onAppear {
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}

// MARK: - Pro Badge (decorative, non-interactive)
/// Reusable "PRO" shield used in headers/paywall. Optional shimmer for promo surfaces.
struct ProBadge: View {
    var color: Color = .white
    /// When true, applies shimmer overlay. Use on paywall only; headers use false.
    var showShimmer: Bool = false

    var body: some View {
        Text("PRO")
            .font(.system(.caption2, weight: .medium).width(.expanded))
            .foregroundColor(color)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(color, lineWidth: 0.6)
            )
            .overlay(shimmerOverlay)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var shimmerOverlay: some View {
        if showShimmer {
            ShimmerOverlay(duration: 4)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .blendMode(.plusLighter)
        }
    }
}

// MARK: - Free Upsell Chip
/// Free-mode CTA chip shown beside PRO in headers. Optionally tappable to open paywall.
struct TestNowForFreeChip: View {
    var color: Color = .white
    var onTap: (() -> Void)?

    @Environment(\.layoutMetrics) private var layoutMetrics

    var body: some View {
        Group {
            if let onTap {
                Button {
                    HapticManager.shared.lightImpact()
                    onTap()
                } label: {
                    label
                }
                .buttonStyle(.plain)
            } else {
                label
            }
        }
    }

    private var label: some View {
        Text("header_test_now_for_free".localized)
            .font(.system(.caption2, weight: .medium).width(.expanded))
            .foregroundColor(color)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .padding(.horizontal, layoutMetrics.adaptive(8))
            .padding(.vertical, layoutMetrics.adaptive(4))
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color("PromoBadge"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(color, lineWidth: 0.6)
            )
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .contentShape(Rectangle())
    }
}

// MARK: - Pro Button
/// Pro badge button that opens paywall. Reusable across the app.
struct ProButton: View {
    let action: () -> Void

    /// Foreground color (e.g. .white on dark headers, .primary on light).
    var color: Color = .white

    @Environment(\.layoutMetrics) private var layoutMetrics

    var body: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            action()
        }) {
            Text("pro_accessibility_label".localized.uppercased())
                .font(.system(.footnote, weight: .regular).width(.expanded))
                .foregroundColor(color)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, layoutMetrics.adaptive(8))
                .padding(.vertical, layoutMetrics.adaptive(4))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(color, lineWidth: 0.6)
                )
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("pro_accessibility_label".localized)
        .accessibilityHint("pro_accessibility_hint".localized)
    }
}

// MARK: - Preview
#Preview("Pro button") {
    ProButton(action: {}, color: .white)
        .padding()
        .background(Color.blue)
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

