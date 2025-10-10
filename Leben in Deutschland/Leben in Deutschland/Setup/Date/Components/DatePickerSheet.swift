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
    
    @State private var isSavePressed = false
    @State private var isClearPressed = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                // Date Picker Wheel
                DatePicker(
                    "SELECT_DATE".localized,
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .environment(\.locale, locale)
                .tint(Color("Fill"))
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    // Save Button
                    Text("SAVE_DATE".localized)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Fill"))
                        .cornerRadius(12)
                        .scaleEffect(isSavePressed ? 0.97 : 1.0)
                        .animation(.easeInOut(duration: 0.08), value: isSavePressed)
                        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                            isSavePressed = pressing
                        }, perform: {
                            onSave(selectedDate)
                        })
                    
                    // Clear Button (only if date exists)
                    if hasExistingDate, let clearAction = onClear {
                        Text("CLEAR_DATE".localized)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                            .scaleEffect(isClearPressed ? 0.97 : 1.0)
                            .animation(.easeInOut(duration: 0.08), value: isClearPressed)
                            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                                isClearPressed = pressing
                            }, perform: {
                                clearAction()
                            })
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("CANCEL".localized) {
                        onCancel()
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .tint(Color("Fill"))
                }
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
