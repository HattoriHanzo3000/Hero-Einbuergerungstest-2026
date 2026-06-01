//
//  AllQuestionsJumpSheet.swift
//  Leben in Deutschland
//
//  Sheet to jump to a question by number (1–310) in All Questions mode.
//

import SwiftUI

struct AllQuestionsJumpSheet: View {
    let totalCount: Int
    let initialNumber: Int
    let onJump: (Int) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager

    @FocusState private var isFieldFocused: Bool
    @State private var inputText: String = ""
    @State private var showInvalidInput = false

    private var canSubmit: Bool {
        parsedNumber != nil
    }

    private var parsedNumber: Int? {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let number = Int(trimmed) else { return nil }
        guard number >= 1, number <= totalCount else { return nil }
        return number
    }

    var body: some View {
        VStack(spacing: layoutMetrics.adaptive(20)) {
            VStack(alignment: .leading, spacing: layoutMetrics.adaptive(8)) {
                Text("all_questions_jump_title".localized)
                    .font(.system(.title2, weight: .semibold))
                    .foregroundColor(.primary)

                Text(String(format: "all_questions_jump_hint".localized, totalCount))
                    .font(.system(.body, weight: .regular))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, layoutMetrics.adaptive(24))

            TextField("all_questions_jump_placeholder".localized, text: $inputText)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .font(.system(.title, weight: .medium).monospacedDigit())
                .multilineTextAlignment(.center)
                .padding(.vertical, layoutMetrics.adaptive(14))
                .padding(.horizontal, layoutMetrics.adaptive(16))
                .background(
                    RoundedRectangle(cornerRadius: layoutMetrics.adaptive(12), style: .continuous)
                        .fill(Color(.secondarySystemFill))
                )
                .focused($isFieldFocused)
                .onChange(of: inputText) { _, newValue in
                    showInvalidInput = false
                    inputText = Self.filteredDigits(newValue, maxLength: 3)
                }
                .accessibilityLabel("all_questions_jump_field_accessibility_label".localized)

            if showInvalidInput {
                Text(String(format: "all_questions_jump_error_invalid".localized, totalCount))
                    .font(.system(.subheadline, weight: .medium))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer(minLength: 0)

            Button {
                submit()
            } label: {
                Text("all_questions_jump_go".localizedUppercased())
                    .font(.system(.headline, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, layoutMetrics.adaptive(16))
                    .background(canSubmit ? Color("AppBlueLagoon") : Color(.systemGray3))
                    .cornerRadius(layoutMetrics.adaptive(14))
            }
            .disabled(!canSubmit)
            .accessibilityLabel("all_questions_jump_go".localized)
            .padding(.bottom, layoutMetrics.adaptive(24))
        }
        .padding(.horizontal, layoutMetrics.adaptive(24))
        .background(Color(.systemBackground))
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onAppear {
            inputText = "\(initialNumber)"
            isFieldFocused = true
        }
    }

    private func submit() {
        guard let number = parsedNumber else {
            showInvalidInput = true
            HapticManager.shared.lightImpact()
            return
        }
        HapticManager.shared.lightImpact()
        onJump(number)
        dismiss()
    }

    private static func filteredDigits(_ value: String, maxLength: Int) -> String {
        let digits = value.filter(\.isNumber)
        return String(digits.prefix(maxLength))
    }
}
