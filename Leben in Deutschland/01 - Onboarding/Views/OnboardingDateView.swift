import SwiftUI

// MARK: - Onboarding Date View
struct OnboardingDateView: View {
    @StateObject private var viewModel: OnboardingDateViewModel
    @State private var showDatePicker: Bool = false
    @State private var showDateTooFarAlert: Bool = false
    @State private var tempDate: Date = Date()
    
    init(viewModel: OnboardingDateViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        OnboardingScreenContainer(
            headerStep: OnboardingConstants.dateStep,
            headerMessageKey: viewModel.dialogMessageKey,
            headerMessageParameters: viewModel.dialogParameters,
            headerId: viewModel.dialogMessageKey,
            showDialog: $viewModel.showDialog,
            isNextEnabled: viewModel.hasSelectedDate || viewModel.hasSelectedDontKnow,
            showBackButton: true,
            nextButtonTitleKey: "LET'S GO",
            onNext: viewModel.proceedToNext,
            onBack: {
                HapticManager.shared.lightImpact()
                viewModel.goBack()
            },
            onSetup: viewModel.setupInitialState,
            languageManager: viewModel.languageManager
        ) {
            OnboardingDateSelectionContentComponent(
                selectedDate: $viewModel.selectedDate,
                onSelectDate: {
                    HapticManager.shared.lightImpact()
                    tempDate = viewModel.selectedDate ?? Date()
                    showDatePicker = true
                },
                onDontKnow: {
                    viewModel.chooseDontKnow()
                },
                hasSelectedDate: viewModel.hasSelectedDate,
                hasSelectedDontKnow: viewModel.hasSelectedDontKnow
            )
        }
        .alert("date_too_far_title".localized, isPresented: $showDateTooFarAlert) {
            Button("ok_button".localized) {
                HapticManager.shared.lightImpact()
            }
        } message: {
            Text("date_too_far_message".localized)
        }
        .sheet(isPresented: $showDatePicker) {
            NavigationView {
                VStack(spacing: 20) {
                    Spacer(minLength: 12)
                    DatePicker(
                        "SELECT_DATE".localized,
                        selection: $tempDate,
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .environment(\.locale, viewModel.languageManager.currentLocale)
                    .accentColor(Color.accentColor)
                    
                    saveDateButton
                    
                    Spacer(minLength: 24)
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
    
    private var saveDateButton: some View {
        QuizActionButton(
            "SAVE_DATE".localized,
            style: saveButtonStyle
        ) {
            HapticManager.shared.lightImpact()
            let tooFar = isDateTooFar(tempDate)
            if tooFar {
                showDatePicker = false
                showDateTooFarAlert = true
            } else {
                viewModel.chooseDate(tempDate)
                showDatePicker = false
            }
        }
        .padding(.horizontal)
    }
    
    private var saveButtonStyle: QuizActionButton.Style {
        QuizActionButton.Style(
            backgroundColor: Color("AppBlueLagoon"),
            disabledBackgroundColor: Color(.systemGray2),
            haloPrimaryColor: Color("AppBlueLagoon").opacity(0.36),
            haloSecondaryColor: Color.white.opacity(0.18),
            suppressGlow: true
        )
    }
    
    private func isDateTooFar(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: date)
        guard let days = calendar.dateComponents([.day], from: start, to: end).day else {
            return false
        }
        return days > 365
    }
}

// MARK: - Preview
#Preview {
    let manager = LanguageManager()
    let vm = OnboardingDateViewModel(languageManager: manager)
    OnboardingDateView(viewModel: vm)
}
