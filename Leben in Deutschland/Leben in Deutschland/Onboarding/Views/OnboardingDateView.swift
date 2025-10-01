import SwiftUI


// MARK: - Onboarding Date View
struct OnboardingDateView: View {
    @ObservedObject var viewModel: OnboardingDateViewModel
    @State private var showDatePicker: Bool = false
    @State private var nextPlayToken: UUID? = nil

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                OnboardingHeader(
                    currentStep: OnboardingConstants.dateStep,
                    totalSteps: OnboardingConstants.totalSteps,
                    showBackButton: true,
                    backAction: {
                        HapticManager.shared.lightImpact()
                        viewModel.goBack()
                    }
                )
                
                // Mascot Dialog
                OnboardingMascotDialog(
                    messageKey: viewModel.dialogMessageKey,
                    messageParameters: viewModel.dialogParameters,
                    showDialog: $viewModel.showDialog,
                    playSignal: nextPlayToken,
                    onPlayCompleted: { viewModel.proceedToNext() }
                )
                .id(viewModel.dialogMessageKey)
                
                // Date selection section
                DateSelectionContent(
                    selectedDate: $viewModel.selectedDate,
                    onSelectDate: { HapticManager.shared.lightImpact(); showDatePicker = true },
                    onDontKnow: { viewModel.chooseDontKnow() },
                    hasSelectedDate: viewModel.hasSelectedDate,
                    hasSelectedDontKnow: viewModel.hasSelectedDontKnow,
                    showDialog: $viewModel.showDialog
                )
                
                Spacer()
                
                // Next Button
                OnboardingNextButton(
                    isEnabled: viewModel.hasSelectedDate || viewModel.hasSelectedDontKnow,
                    action: { nextPlayToken = UUID() },
                    showDialog: $viewModel.showDialog
                )
            }
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
                    .environment(\.locale, currentLocale())
                    .accentColor(Color.accentColor)
                    
                    Button("SAVE_DATE".localized) {
                        HapticManager.shared.lightImpact()
                        viewModel.hasSelectedDate = true
                        viewModel.hasSelectedDontKnow = false
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
        .onAppear { viewModel.setupInitialState() }
        .environmentObject(viewModel.languageManager)
    }
}

// MARK: - Helpers
extension OnboardingDateView {
    private func currentLocale() -> Locale {
        let code = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        switch code {
        case "ru": return Locale(identifier: "ru_RU")
        case "de": return Locale(identifier: "de_DE")
        case "uk": return Locale(identifier: "uk_UA")
        default: return Locale(identifier: "en_US")
        }
    }

    private func formatDateForButton(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = currentLocale()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    // (Dialog logic now lives in viewModel.dialogMessageKey)
}

// MARK: - Preview
#Preview {
    let manager = LanguageManager()
    let vm = OnboardingDateViewModel(languageManager: manager)
    return OnboardingDateView(viewModel: vm)
}


