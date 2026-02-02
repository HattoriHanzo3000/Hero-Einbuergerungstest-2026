//
//  TrialOfferBanner.swift
//  Leben in Deutschland
//
//  Banner showing free trial offer
//

import SwiftUI

struct TrialOfferBanner: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    var body: some View {
        HStack(spacing: layoutMetrics.adaptive(12)) {
            Image(systemName: "gift.fill")
                .font(.system(size: layoutMetrics.adaptive(24), weight: .semibold))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: layoutMetrics.adaptive(4)) {
                Text("premium_trial_offer_title".localized)
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(.white)
                
                Text("premium_trial_offer_description".localized)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Spacer()
        }
        .padding(layoutMetrics.adaptive(16))
        .background(
            RoundedRectangle(cornerRadius: layoutMetrics.adaptive(16), style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.green,
                            Color.green.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: Color.green.opacity(0.3), radius: 8, y: 4)
    }
}

// MARK: - Preview
#Preview {
    TrialOfferBanner()
        .padding()
        .background(Color(.systemBackground))
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

