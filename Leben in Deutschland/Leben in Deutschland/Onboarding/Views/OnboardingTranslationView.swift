import SwiftUI

// MARK: - Onboarding Translation View
struct OnboardingTranslationView: View {
    @StateObject private var viewModel: OnboardingTranslationViewModel
    @State private var nextPlayToken: UUID? = nil

    init(viewModel: OnboardingTranslationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header island with progress and mascot
                OnboardingHeaderComponent(
                    currentStep: OnboardingConstants.translationStep,
                    totalSteps: OnboardingConstants.totalSteps,
                    messageKey: "translation_selection_title",
                    showDialog: $viewModel.showDialog,
                    playSignal: nextPlayToken,
                    onPlayCompleted: { viewModel.proceedToNext() }
                )
                .id(viewModel.selectedLanguage)
                .padding(.top, 8)
                
                // Translation Language Selection Content
                OnboardingTranslationSelectionContentComponent(
                    selectedLanguage: $viewModel.selectedLanguage,
                    onLanguageSelected: viewModel.selectLanguage,
                    showDialog: $viewModel.showDialog
                )
                
                Spacer()
                
                // Next Button with back button
                OnboardingNextButtonComponent(
                    isEnabled: viewModel.selectedLanguage != nil,
                    action: { nextPlayToken = UUID() },
                    showDialog: $viewModel.showDialog,
                    showBackButton: true,
                    backAction: viewModel.goBack
                )
            }
        }
        .onAppear {
            viewModel.setupInitialState()
        }
        .environmentObject(viewModel.languageManager)
    }
}

// MARK: - Preview
#Preview {
    // Preview with a temporary manager
    let manager = LanguageManager()
    let vm = OnboardingTranslationViewModel(languageManager: manager)
    return OnboardingTranslationView(viewModel: vm)
}
