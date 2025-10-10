import SwiftUI

// MARK: - Onboarding Language View
struct OnboardingLanguageView: View {
    @StateObject private var viewModel: OnboardingLanguageViewModel
    @State private var nextPlayToken: UUID? = nil

    init(viewModel: OnboardingLanguageViewModel) {
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
                    currentStep: OnboardingConstants.languageStep,
                    totalSteps: OnboardingConstants.totalSteps,
                    showBackButton: false,
                    backAction: nil
                )
                
                // Mascot Dialog
                OnboardingMascotDialog(
                    messageKey: "eagle_greeting",
                    showDialog: $viewModel.showDialog,
                    playSignal: nextPlayToken,
                    onPlayCompleted: { viewModel.proceedToNext() }
                )
                .id(viewModel.selectedLanguage)
                
                // Language Selection Content
                LanguageSelectionContent(
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
    let vm = OnboardingLanguageViewModel(languageManager: manager) { }
    OnboardingLanguageView(viewModel: vm)
}

