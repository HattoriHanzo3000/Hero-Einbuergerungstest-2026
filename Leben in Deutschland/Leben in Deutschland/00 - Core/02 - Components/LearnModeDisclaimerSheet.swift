//
//  LearnModeDisclaimerSheet.swift
//  Leben in Deutschland
//
//  Reusable disclaimer sheet for learn modes: title, message, "Don't show again" checkbox, OK button.
//  Used by SpacedRepetitionView and AllQuestionsView.
//

import SwiftUI

struct LearnModeDisclaimerSheet: View {
    let titleKey: String
    let messageKey: String
    let accentColor: Color
    @Binding var doNotShowAgain: Bool
    let onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager

    var body: some View {
        VStack(spacing: layoutMetrics.adaptive(24)) {
            VStack(alignment: .leading, spacing: layoutMetrics.adaptive(12)) {
                Text(titleKey.localized)
                    .font(.system(.title2, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                Text(messageKey.localized)
                    .font(.system(.body, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(.top, layoutMetrics.adaptive(24))

            Button {
                HapticManager.shared.lightImpact()
                doNotShowAgain.toggle()
            } label: {
                HStack(spacing: layoutMetrics.adaptive(12)) {
                    Image(systemName: doNotShowAgain ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: layoutMetrics.adaptive(22)))
                        .foregroundColor(doNotShowAgain ? accentColor : .secondary)
                    Text("sr_disclaimer_do_not_show".localized)
                        .font(.system(.body, weight: .medium))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("sr_disclaimer_do_not_show".localized)
            .accessibilityHint(doNotShowAgain ? "Checked" : "Unchecked")
            .accessibilityAddTraits(doNotShowAgain ? [.isButton, .isSelected] : .isButton)

            Spacer(minLength: 0)

            Button {
                HapticManager.shared.lightImpact()
                onDismiss()
                dismiss()
            } label: {
                Text("ok_button".localized)
                    .font(.system(.headline, weight: .semibold))
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
