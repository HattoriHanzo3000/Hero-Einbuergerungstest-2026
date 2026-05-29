//
//  LearnModeDisclaimerSheet.swift
//  Leben in Deutschland
//
//  Reusable disclaimer sheet for learn modes: title, message, optional "Don't show again" checkbox, OK button.
//  Used by SpacedRepetitionView, AllQuestionsView, and Progress (HomeStatisticsSection).
//

import SwiftUI

struct LearnModeDisclaimerSheet: View {
    let titleKey: String
    let messageKey: String
    /// When provided, used instead of messageKey.localized (e.g. for formatted strings).
    var messageFormatted: String? = nil
    /// When provided, used instead of messageText. Use for rich content (e.g. colored level names).
    var customMessageContent: AnyView? = nil
    let accentColor: Color
    @Binding var doNotShowAgain: Bool
    /// When false, hides the "Don't show again" checkbox. Use for Progress info.
    var showDoNotShowAgain: Bool = true
    let onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager

    private var messageText: String {
        messageFormatted ?? messageKey.localized
    }

    var body: some View {
        VStack(spacing: layoutMetrics.adaptive(24)) {
            VStack(alignment: .leading, spacing: layoutMetrics.adaptive(12)) {
                Text(titleKey.localized)
                    .font(.system(.title2, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                if let content = customMessageContent {
                    content
                } else {
                    Text(messageText)
                        .font(.system(.body, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.top, layoutMetrics.adaptive(24))

            if showDoNotShowAgain {
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
            }

            Spacer(minLength: 0)

            Button {
                HapticManager.shared.lightImpact()
                onDismiss()
                dismiss()
            } label: {
                Text("ok_button".localizedUppercased())
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
