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
                // Header with Progress Bar
                OnboardingHeader(
                    currentStep: OnboardingConstants.translationStep,
                    totalSteps: OnboardingConstants.totalSteps,
                    showBackButton: true,
                    backAction: viewModel.goBack
                )
                
                // Mascot Dialog
                OnboardingMascotDialog(
                    messageKey: "translation_selection_title",
                    showDialog: $viewModel.showDialog,
                    playSignal: nextPlayToken,
                    onPlayCompleted: { viewModel.proceedToNext() }
                )
                .id(viewModel.selectedLanguage)
                
                // Translation Language Selection Content
                TranslationLanguageSelectionContent(
                    selectedLanguage: $viewModel.selectedLanguage,
                    onLanguageSelected: viewModel.selectLanguage,
                    showDialog: $viewModel.showDialog
                )
                
                Spacer()
                
                // Next Button
                OnboardingNextButton(
                    isEnabled: viewModel.selectedLanguage != nil,
                    action: { nextPlayToken = UUID() },
                    showDialog: $viewModel.showDialog
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
