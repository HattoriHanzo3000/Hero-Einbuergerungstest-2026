import SwiftUI

/// Entry point for the modular Settings experience.
/// This view will orchestrate the individual settings sections using MVVM.
@MainActor
struct SettingsDashboardView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var stateManager: StateManager
    @EnvironmentObject private var soundManager: SoundManager
    @EnvironmentObject private var appFlow: AppFlow
    @StateObject private var viewModel: SettingsDashboardViewModel

    init(viewModel: SettingsDashboardViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? SettingsDashboardViewModel())
    }

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            List {
                SettingsInfoSectionView(
                    onAboutTapped: { viewModel.navigationPath.append(.about) },
                    onShareTapped: { viewModel.navigationPath.append(.share) }
                )
                SettingsPremiumSectionView(viewModel: viewModel.premiumViewModel)
                if let regionalViewModel = viewModel.regionalViewModel {
                    SettingsRegionalSectionView(viewModel: regionalViewModel)
                }
                if let personalisationViewModel = viewModel.personalisationViewModel {
                    SettingsPersonalisationSectionView(viewModel: personalisationViewModel)
                }
                SettingsSupportSectionView(viewModel: viewModel.supportViewModel)
                SettingsLegalSectionView(viewModel: viewModel.legalViewModel)
                if let dangerViewModel = viewModel.dangerViewModel {
                    SettingsDangerSectionView(viewModel: dangerViewModel)
                }
            }
            .id(languageManager.currentAppLanguage)
            .navigationTitle("settings_title".localized)
            .navigationBarTitleDisplayMode(.large)
            .listStyle(.insetGrouped)
            .federalStateAlert(viewModel: viewModel.regionalViewModel)
            .navigationDestination(for: SettingsDashboardRoute.self) { route in
                switch route {
                case .about:
                    SettingsAboutView()
                case .share:
                    SettingsShareView()
                case .premium:
                    EmptyView()
                }
            }
        }
        .task {
            viewModel.configureRegionalSection(
                languageManager: languageManager,
                stateManager: stateManager
            )
            viewModel.configurePersonalisationSection(
                soundManager: soundManager
            )
            viewModel.configureDangerSection(
                soundManager: soundManager,
                languageManager: languageManager,
                stateManager: stateManager
            ) { [appFlow] in
                appFlow.stage = .startAnimation
            }
        }
        .sheet(item: contactMailBinding) { mail in
            MailComposer(
                toRecipients: mail.recipients,
                subject: mail.subject,
                messageBody: mail.body
            )
        }
    }

    private var contactMailBinding: Binding<SettingsSupportMailModel?> {
        Binding(
            get: { viewModel.supportViewModel.presentedContactMail },
            set: { _ in
                viewModel.supportViewModel.dismissContactMail()
            }
        )
    }

}

#Preview("Settings Dashboard") {
    SettingsDashboardView()
        .environmentObject(LanguageManager())
        .environmentObject(SoundManager.shared)
        .environmentObject(StateManager.shared)
        .environmentObject(AppFlow())
}

