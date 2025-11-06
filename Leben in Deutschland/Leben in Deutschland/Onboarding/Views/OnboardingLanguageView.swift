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
                // Header island with progress and mascot
                OnboardingHeaderComponent(
                    currentStep: OnboardingConstants.languageStep,
                    totalSteps: OnboardingConstants.totalSteps,
                    messageKey: "eagle_greeting",
                    showDialog: $viewModel.showDialog,
                    playSignal: nextPlayToken,
                    onPlayCompleted: { viewModel.proceedToNext() }
                )
                .id(viewModel.selectedLanguage)
                .padding(.top, 8)
                
                // Language Selection Content
                OnboardingLanguageSelectionContentComponent(
                    selectedLanguage: $viewModel.selectedLanguage,
                    onLanguageSelected: viewModel.selectLanguage,
                    showDialog: $viewModel.showDialog
                )
                .transaction { transaction in transaction.animation = nil }
                
                Spacer()
                
                // Next Button (no back button on first screen)
                OnboardingNextButtonComponent(
                    isEnabled: viewModel.selectedLanguage != nil,
                    action: { nextPlayToken = UUID() },
                    showDialog: $viewModel.showDialog,
                    showBackButton: false,
                    backAction: nil
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

