import SwiftUI

// MARK: - Onboarding State View
struct OnboardingStateView: View {
    @ObservedObject var viewModel: OnboardingStateViewModel
    @State private var nextPlayToken: UUID? = nil
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                OnboardingHeader(
                    currentStep: OnboardingConstants.stateStep,
                    totalSteps: OnboardingConstants.totalSteps,
                    showBackButton: true,
                    backAction: viewModel.goBack
                )
                
                OnboardingMascotDialog(
                    messageKey: viewModel.dialogMessageKey,
                    showDialog: $viewModel.showDialog,
                    playSignal: nextPlayToken,
                    onPlayCompleted: { viewModel.proceedToNext() }
                )
                .id(viewModel.selectedState)
                
                StateSelectionContent(
                    selectedState: $viewModel.selectedState,
                    onStateSelected: viewModel.selectState,
                    showDialog: $viewModel.showDialog
                )
                .padding(.vertical, 10)
                
                OnboardingNextButton(
                    isEnabled: viewModel.selectedState != nil,
                    action: { nextPlayToken = UUID() },
                    showDialog: $viewModel.showDialog
                )
            }
        }
        .onAppear { viewModel.setupInitialState() }
        .environmentObject(viewModel.languageManager)
    }
}

// MARK: - Preview
#Preview {
    let manager = LanguageManager()
    let vm = OnboardingStateViewModel(languageManager: manager)
    return OnboardingStateView(viewModel: vm)
}
