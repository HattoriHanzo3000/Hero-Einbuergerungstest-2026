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
    #if DEBUG
    @State private var showDebugMenu = false
    #endif

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

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
                SettingsProSectionView(viewModel: viewModel.proViewModel)
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
                Section {
                    HStack {
                        Spacer()
                        Text("\("version".localized) \(appVersion)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .accessibilityLabel("version".localized)
                            .accessibilityValue(appVersion)
                            #if DEBUG
                            .onTapGesture(count: 7) {
                                showDebugMenu = true
                            }
                            #endif
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .id(languageManager.currentAppLanguage)
            .navigationTitle("settings_title".localized)
            .navigationBarTitleDisplayMode(.large)
            .listStyle(.insetGrouped)
            .federalStateAlert(viewModel: viewModel.regionalViewModel)
            .languageChangeAlert(viewModel: viewModel.regionalViewModel)
            .navigationDestination(for: SettingsDashboardRoute.self) { route in
                switch route {
                case .about:
                    SettingsAboutView()
                case .share:
                    SettingsShareView()
                case .heroProPlan:
                    SettingsHeroProPlanView()
                }
            }
        }
        .toolbar(viewModel.navigationPath.isEmpty ? .visible : .hidden, for: .tabBar)
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
                messageBody: mail.body,
                onDismiss: { viewModel.supportViewModel.dismissContactMail() }
            )
        }
        .sheet(isPresented: faqSheetBinding, onDismiss: { viewModel.supportViewModel.dismissFAQ() }) {
            if let url = viewModel.supportViewModel.faqURL {
                SafariSheetView(url: url)
            } else {
                Text("FAQ is currently unavailable.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
        .sheet(item: legalWebBinding, onDismiss: { viewModel.legalViewModel.dismissWeb() }) { document in
            SafariSheetView(url: document.url)
        }
        .alert("mail_unavailable_title".localized, isPresented: Binding(
            get: { viewModel.supportViewModel.showMailUnavailableAlert },
            set: { if !$0 { viewModel.supportViewModel.dismissMailUnavailableAlert() } }
        )) {
            Button("ok_button".localized) {
                viewModel.supportViewModel.dismissMailUnavailableAlert()
            }
        } message: {
            Text("mail_unavailable_message".localized)
        }
        #if DEBUG
        .sheet(isPresented: $showDebugMenu) {
            DebugMenuSheet()
        }
        #endif
        .overlay {
            if languageManager.isApplyingLanguageChange || (viewModel.regionalViewModel?.isApplyingStateChange ?? false) {
                Color(.systemBackground)
                    .ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("AppBlueLagoon")))
                    Text("LOADING".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: languageManager.isApplyingLanguageChange || (viewModel.regionalViewModel?.isApplyingStateChange ?? false))
            }
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

    private var faqSheetBinding: Binding<Bool> {
        Binding(
            get: { viewModel.supportViewModel.isPresentingFAQ },
            set: { if !$0 { viewModel.supportViewModel.dismissFAQ() } }
        )
    }

    private var legalWebBinding: Binding<SettingsLegalViewModel.LegalDocument?> {
        Binding(
            get: { viewModel.legalViewModel.presentingWebURL },
            set: { viewModel.legalViewModel.presentingWebURL = $0 }
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

