import SwiftUI

// MARK: - Onboarding Date View
struct OnboardingDateView: View {
    @StateObject private var viewModel: OnboardingDateViewModel
    @State private var showDatePicker: Bool = false
    @State private var showDateTooFarDialog: Bool = false
    @State private var tempDate: Date = Date()
    
    init(viewModel: OnboardingDateViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
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
                        withAnimation {
                            showDateTooFarDialog = false
                        }
                        showDatePicker = true
                    },
                    onDontKnow: {
                        viewModel.chooseDontKnow()
                        withAnimation {
                            showDateTooFarDialog = false
                        }
                    },
                    hasSelectedDate: viewModel.hasSelectedDate,
                    hasSelectedDontKnow: viewModel.hasSelectedDontKnow
                )
            }
            .zIndex(0)
            
            DateTooFarDialog(
                isPresented: showDateTooFarDialog,
                onDismiss: {
                    withAnimation {
                        showDateTooFarDialog = false
                    }
                }
            )
            .zIndex(1)
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
                    
                    Button("SAVE_DATE".localized) {
                        HapticManager.shared.lightImpact()
                        let tooFar = isDateTooFar(tempDate)
                        if tooFar {
                            showDatePicker = false
                            withAnimation {
                                showDateTooFarDialog = true
                            }
                        } else {
                            viewModel.chooseDate(tempDate)
                            showDatePicker = false
                            withAnimation {
                                showDateTooFarDialog = false
                            }
                        }
                    }
                    .font(.title3.bold())
                    .fontDesign(.rounded)
                    .foregroundColor(Color(.systemGray6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.accentColor)
                    )
                    .padding(.horizontal)
                    
                    Spacer(minLength: 24)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("CANCEL".localized) {
                            HapticManager.shared.lightImpact()
                            showDatePicker = false
                        }
                        .font(.title3.bold())
                        .fontDesign(.rounded)
                        .tint(Color("Fill"))
                    }
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
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
