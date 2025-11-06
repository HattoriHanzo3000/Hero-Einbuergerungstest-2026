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
                // Header island with progress and mascot
                OnboardingHeaderComponent(
                    currentStep: OnboardingConstants.stateStep,
                    totalSteps: OnboardingConstants.totalSteps,
                    messageKey: viewModel.dialogMessageKey,
                    showDialog: $viewModel.showDialog,
                    playSignal: nextPlayToken,
                    onPlayCompleted: { viewModel.proceedToNext() }
                )
                .id(viewModel.selectedState)
                .padding(.top, 8)
                
                OnboardingStateSelectionContentComponent(
                    selectedState: $viewModel.selectedState,
                    onStateSelected: viewModel.selectState,
                    showDialog: $viewModel.showDialog
                )
                .padding(.vertical, 10)
                
                // Next Button with back button
                OnboardingNextButtonComponent(
                    isEnabled: viewModel.selectedState != nil,
                    action: { nextPlayToken = UUID() },
                    showDialog: $viewModel.showDialog,
                    showBackButton: true,
                    backAction: viewModel.goBack
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
