//
//  CategoriesTabHeaderCard.swift
//  Leben in Deutschland
//
//  Header for Categories tab. Layout: back | premium (top row), mascot + message (bottom row).
//  When useCard is false, renders content only for flat gradient headers (same as Home).
//

import SwiftUI

// MARK: - Categories Tab Header Card
struct CategoriesTabHeaderCard: View {
    var onBackTapped: () -> Void
    var onPremiumTap: () -> Void
    /// When false, renders content only for flat gradient headers (no rounded card).
    var useCard: Bool = true

    @Environment(\.layoutMetrics) private var layoutMetrics

    private var mascotToContentSpacing: CGFloat { layoutMetrics.adaptive(16) }
    private var mascotSize: CGFloat { layoutMetrics.adaptive(120) }

    private var headerContent: some View {
        VStack(alignment: .leading, spacing: layoutMetrics.adaptive(6)) {
            HStack {
                AdaptiveIconButton.backButton(action: onBackTapped, tintColor: .white)
                Spacer()
                PremiumButton(action: onPremiumTap, color: .white)
            }
            .transaction { $0.animation = nil }

            HStack(alignment: .center, spacing: mascotToContentSpacing) {
                MascotView(autoPlayInterval: 60)
                    .frame(width: mascotSize, height: mascotSize)
                Text("learn_by_topics_header_message".localized)
                    .font(.system(.body, weight: .semibold))
                    .italic()
                    .lineSpacing(4)
                    .foregroundColor(.white.opacity(0.92))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }

    var body: some View {
        Group {
            if useCard {
                HeaderCard(gradient: .blue, showPremiumButton: false) {
                    headerContent
                }
            } else {
                headerContent
            }
        }
        .transaction { $0.animation = nil }
    }
}
