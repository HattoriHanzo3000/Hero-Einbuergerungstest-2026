//
//  PremiumComparisonTable.swift
//  Leben in Deutschland
//
//  Comparison table showing Free vs Premium features
//

import SwiftUI

struct PremiumComparisonTable: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    var body: some View {
        VStack(spacing: 0) {
            // Header row
            HStack(spacing: 0) {
                // Benefits column
                Text("premium_table_benefits".localized)
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(layoutMetrics.adaptive(16))
                
                Divider()
                
                // Free column
                Text("premium_table_free".localized)
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(.primary)
                    .frame(width: layoutMetrics.adaptive(80))
                    .padding(layoutMetrics.adaptive(16))
                
                Divider()
                
                // Premium column
                Text("premium_table_premium".localized)
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(Color("AppOrange"))
                    .frame(width: layoutMetrics.adaptive(80))
                    .padding(layoutMetrics.adaptive(16))
            }
            .background(Color(.systemGray6).opacity(0.5))
            
            Divider()
            
            // Feature rows
            ForEach(Array(PremiumFeatureModel.features.enumerated()), id: \.element.nameKey) { index, feature in
                PremiumFeatureRow(feature: feature)
                
                if index < PremiumFeatureModel.features.count - 1 {
                    Divider()
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: layoutMetrics.adaptive(20), style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: layoutMetrics.adaptive(20), style: .continuous)
                        .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 4)
    }
}

// MARK: - Feature Row
private struct PremiumFeatureRow: View {
    let feature: PremiumFeatureModel
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    var body: some View {
        HStack(spacing: 0) {
            // Feature name
            Text(feature.nameKey.localized)
                .font(.system(.body, design: .rounded).weight(.medium))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(layoutMetrics.adaptive(16))
            
            Divider()
            
            // Free status
            Image(systemName: feature.isAvailableInFree ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: layoutMetrics.adaptive(20), weight: .semibold))
                .foregroundColor(feature.isAvailableInFree ? .green : .red.opacity(0.6))
                .frame(width: layoutMetrics.adaptive(80))
                .padding(layoutMetrics.adaptive(16))
            
            Divider()
            
            // Premium status
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: layoutMetrics.adaptive(20), weight: .semibold))
                .foregroundColor(Color("AppOrange"))
                .frame(width: layoutMetrics.adaptive(80))
                .padding(layoutMetrics.adaptive(16))
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview
#Preview {
    PremiumComparisonTable()
        .padding()
        .background(Color(.systemBackground))
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

