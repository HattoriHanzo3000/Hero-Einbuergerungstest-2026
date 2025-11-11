import SwiftUI

// MARK: - Onboarding Translation View
struct OnboardingTranslationView: View {
    @StateObject private var viewModel: OnboardingTranslationViewModel

    init(viewModel: OnboardingTranslationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        OnboardingScreenContainer(
            headerStep: OnboardingConstants.translationStep,
            headerMessageKey: "translation_selection_title",
            headerId: viewModel.selectedLanguage,
            showDialog: $viewModel.showDialog,
            isNextEnabled: viewModel.selectedLanguage != nil,
            showBackButton: true,
            onNext: viewModel.proceedToNext,
            onBack: viewModel.goBack,
            onSetup: viewModel.setupInitialState,
            languageManager: viewModel.languageManager
        ) {
            OnboardingTranslationSelectionContentComponent(
                selectedLanguage: $viewModel.selectedLanguage,
                onLanguageSelected: viewModel.selectLanguage
            )
        }
    }
}

// MARK: - Preview
#Preview {
    let manager = LanguageManager()
    let vm = OnboardingTranslationViewModel(languageManager: manager)
    OnboardingTranslationView(viewModel: vm)
}
