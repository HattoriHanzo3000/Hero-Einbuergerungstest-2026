//
//  DatePickerSheet.swift
//  Leben in Deutschland
//
//  Date picker modal component
//

import SwiftUI

// MARK: - Date Picker Sheet
struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    let locale: Locale
    let hasExistingDate: Bool
    let onSave: (Date) -> Void
    let onClear: (() -> Void)?
    let onCancel: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var tempDate: Date = Date()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                DatePicker(
                    "SELECT_DATE".localized,
                    selection: $tempDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .environment(\.locale, locale)
                .tint(Color("Fill"))

                Spacer()

                VStack(spacing: 0) {
                    Button("SAVE_DATE".localized) {
                        HapticManager.shared.lightImpact()
                        onSave(tempDate)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)

                    if hasExistingDate, let clearAction = onClear {
                        Divider().background(Color(.separator))
                        Button("CLEAR_DATE".localized, role: .destructive) {
                            HapticManager.shared.lightImpact()
                            clearAction()
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )
                .padding(.horizontal)

                Spacer(minLength: 24)
            }
            .padding(.horizontal)
            .navigationBarHidden(true)
            .onAppear {
                tempDate = selectedDate
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Preview
#Preview {
    DatePickerSheet(
        selectedDate: .constant(Date()),
        locale: Locale(identifier: "en_US"),
        hasExistingDate: true,
        onSave: { _ in },
        onClear: {},
        onCancel: {}
    )
}
