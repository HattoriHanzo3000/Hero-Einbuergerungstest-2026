//
//  CategoriesTabHeaderCard.swift
//  Leben in Deutschland
//
//  Header card for Categories tab. Layout: back | crown | search (top row),
//  mascot + message (bottom row). Uses HeaderCard for styling.
//  NO ANIMATION — icon and content update instantly.
//

import SwiftUI

// MARK: - Categories Tab Header Card
struct CategoriesTabHeaderCard: View {
    var onBackTapped: () -> Void
    var onPremiumTap: () -> Void

    @Environment(\.layoutMetrics) private var layoutMetrics

    private var mascotToContentSpacing: CGFloat { layoutMetrics.adaptive(16) }
    private var mascotSize: CGFloat { layoutMetrics.adaptive(120) }

    var body: some View {
        HeaderCard(gradient: .blue, showPremiumButton: false) {
            VStack(alignment: .leading, spacing: layoutMetrics.adaptive(6)) {
                HStack {
                    AdaptiveIconButton.backButton(action: onBackTapped, tintColor: .white)
                    Spacer()
                    PremiumCrownButton(action: onPremiumTap, color: .white)
                }
                .transaction { $0.animation = nil }

                HStack(alignment: .center, spacing: mascotToContentSpacing) {
                    MascotView(autoPlayInterval: 60)
                        .frame(width: mascotSize, height: mascotSize)
                    Text("learn_by_topics_header_message".localized)
                        .font(.system(.body, design: .rounded).weight(.medium))
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
        .transaction { $0.animation = nil }
    }
}
