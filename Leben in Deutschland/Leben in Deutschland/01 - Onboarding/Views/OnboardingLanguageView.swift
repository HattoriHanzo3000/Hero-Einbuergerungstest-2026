import SwiftUI

// MARK: - Onboarding Language View
struct OnboardingLanguageView: View {
    @StateObject private var viewModel: OnboardingLanguageViewModel

    init(viewModel: OnboardingLanguageViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        OnboardingScreenContainer(
            headerStep: OnboardingConstants.languageStep,
            headerMessageKey: viewModel.dialogMessageKey,
            headerId: viewModel.selectedLanguage,
            showDialog: $viewModel.showDialog,
            isNextEnabled: viewModel.selectedLanguage != nil,
            showBackButton: false,
            onNext: viewModel.proceedToNext,
            onBack: nil,
            onSetup: viewModel.setupInitialState,
            languageManager: viewModel.languageManager,
            disableContentAnimation: true
        ) {
            OnboardingLanguageSelectionContentComponent(
                selectedLanguage: $viewModel.selectedLanguage,
                onLanguageSelected: viewModel.selectLanguage
            )
        }
    }
}

// MARK: - Preview
#Preview {
    let manager = LanguageManager()
    let vm = OnboardingLanguageViewModel(languageManager: manager) { }
    OnboardingLanguageView(viewModel: vm)
}

