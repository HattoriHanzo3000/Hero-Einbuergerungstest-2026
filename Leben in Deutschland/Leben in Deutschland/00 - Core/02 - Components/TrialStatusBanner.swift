//
//  TrialStatusBanner.swift
//  Leben in Deutschland
//
//  Banner showing free trial status
//

import SwiftUI

struct TrialStatusBanner: View {
    let daysRemaining: Int
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    var body: some View {
        HStack(spacing: layoutMetrics.adaptive(12)) {
            Image(systemName: "gift.fill")
                .font(.system(size: layoutMetrics.adaptive(20), weight: .semibold))
                .foregroundColor(Color("AppOrange"))
            
            VStack(alignment: .leading, spacing: layoutMetrics.adaptive(4)) {
                Text("premium_trial_active".localized)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
                    .foregroundColor(.primary)
                
                if daysRemaining > 0 {
                    Text("premium_trial_days_remaining".localized.replacingOccurrences(of: "{days}", with: "\(daysRemaining)"))
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                } else {
                    Text("premium_trial_ending_soon".localized)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(layoutMetrics.adaptive(16))
        .background(
            RoundedRectangle(cornerRadius: layoutMetrics.adaptive(12), style: .continuous)
                .fill(Color("AppOrange").opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: layoutMetrics.adaptive(12), style: .continuous)
                        .stroke(Color("AppOrange").opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        TrialStatusBanner(daysRemaining: 3)
        TrialStatusBanner(daysRemaining: 1)
        TrialStatusBanner(daysRemaining: 0)
    }
    .padding()
    .background(Color(.systemBackground))
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

