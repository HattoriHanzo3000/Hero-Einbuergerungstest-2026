//
//  FeaturePreviewDisclaimerSheet.swift
//  Leben in Deutschland
//
//  Shown to free users before the paywall when they tap Learn by Topics, Smart Learning,
//  Favorites, or Test Simulation. Explains what the feature does so they understand
//  what they're unlocking. User swipes down or taps Continue to dismiss, then sees the paywall.
//

import SwiftUI

// MARK: - Feature Preview Disclaimer Sheet
/// Explains a premium feature to free users. Dismissible by swipe or Continue button.
/// Parent's sheet onDismiss presents the paywall.
struct FeaturePreviewDisclaimerSheet: View {
    let titleKey: String
    let messageKey: String
    let accentColorName: String

    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutMetrics) private var layoutMetrics

    private var accentColor: Color {
        Color(accentColorName)
    }

    var body: some View {
        VStack(spacing: layoutMetrics.adaptive(24)) {
            VStack(alignment: .leading, spacing: layoutMetrics.adaptive(12)) {
                Text(titleKey.localized)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                Text(messageKey.localized)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, layoutMetrics.adaptive(24))

            Spacer(minLength: 0)

            Button {
                HapticManager.shared.lightImpact()
                dismiss()
            } label: {
                Text("feature_preview_continue".localizedUppercased())
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, layoutMetrics.adaptive(16))
                    .background(accentColor)
                    .cornerRadius(layoutMetrics.adaptive(14))
            }
            .padding(.bottom, layoutMetrics.adaptive(24))
        }
        .padding(.horizontal, layoutMetrics.adaptive(24))
        .background(Color(.systemBackground))
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Preview
#Preview {
    FeaturePreviewDisclaimerSheet(
        titleKey: "learn_by_topics_disclaimer_title",
        messageKey: "learn_by_topics_disclaimer_message",
        accentColorName: "AppCaribean"
    )
    .environmentObject(LanguageManager())
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 500)))
}
