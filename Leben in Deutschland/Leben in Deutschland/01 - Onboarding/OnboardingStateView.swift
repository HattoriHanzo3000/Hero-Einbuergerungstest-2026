import SwiftUI

// MARK: - Onboarding State View
struct OnboardingStateView: View {
    @StateObject private var viewModel: OnboardingStateViewModel
    
    init(viewModel: OnboardingStateViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        OnboardingScreenContainer(
            headerStep: OnboardingConstants.stateStep,
            headerMessageKey: viewModel.dialogMessageKey,
            headerId: viewModel.selectedState,
            showDialog: $viewModel.showDialog,
            isNextEnabled: viewModel.selectedState != nil,
            showBackButton: true,
            onNext: viewModel.proceedToNext,
            onBack: viewModel.goBack,
            onSetup: viewModel.setupInitialState,
            languageManager: viewModel.languageManager
        ) {
            OnboardingStateSelectionContentComponent(
                selectedState: $viewModel.selectedState,
                onStateSelected: viewModel.selectState
            )
        }
    }
}

// MARK: - Preview
#Preview {
    let manager = LanguageManager()
    let vm = OnboardingStateViewModel(languageManager: manager)
    OnboardingStateView(viewModel: vm)
}
