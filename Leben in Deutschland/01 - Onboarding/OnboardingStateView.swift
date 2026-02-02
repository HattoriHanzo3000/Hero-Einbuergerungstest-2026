#Preview {
    let manager = LanguageManager()
    let stateManager = StateManager()
    let vm = OnboardingStateViewModel(languageManager: manager, stateManager: stateManager)
    OnboardingStateView(viewModel: vm)
        .environmentObject(stateManager)
}
