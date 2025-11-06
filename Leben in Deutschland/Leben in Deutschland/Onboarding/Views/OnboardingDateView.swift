import SwiftUI

// MARK: - Onboarding Date View
struct OnboardingDateView: View {
    @StateObject private var viewModel: OnboardingDateViewModel
    @State private var showDatePicker: Bool = false
    
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
                onSelectDate: { HapticManager.shared.lightImpact(); showDatePicker = true },
                onDontKnow: { viewModel.chooseDontKnow() },
                hasSelectedDate: viewModel.hasSelectedDate,
                hasSelectedDontKnow: viewModel.hasSelectedDontKnow
            )
        }
        .sheet(isPresented: $showDatePicker) {
            NavigationView {
                VStack(spacing: 20) {
                    Spacer()
                    DatePicker(
                        "SELECT_DATE".localized,
                        selection: Binding<Date>(
                            get: { viewModel.selectedDate ?? Date() },
                            set: { viewModel.chooseDate($0) }
                        ),
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .environment(\.locale, viewModel.languageManager.currentLocale)
                    .accentColor(Color.accentColor)
                    
                    Button("SAVE_DATE".localized) {
                        HapticManager.shared.lightImpact()
                        if let selectedDate = viewModel.selectedDate {
                            viewModel.chooseDate(selectedDate)
                        }
                        showDatePicker = false
                    }
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(Color(.systemGray6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("AppOrange"))
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("CANCEL".localized) {
                            HapticManager.shared.lightImpact()
                            showDatePicker = false
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
}

// MARK: - Preview
#Preview {
    let manager = LanguageManager()
    let vm = OnboardingDateViewModel(languageManager: manager)
    OnboardingDateView(viewModel: vm)
}
