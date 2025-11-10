import SwiftUI

// Main Settings View
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @AppStorage("app_appearance") private var appAppearance: String = "system"
    var body: some View {
        ZStack {
            SettingsBackgroundView()
                .ignoresSafeArea()
            
            List {
                Section {
                    SettingsHeaderView()
                        .padding(.top, MainScreenConstants.adaptiveValue(18))
                        .padding(.bottom, MainScreenConstants.adaptiveValue(12))
                        .listRowInsets(.init(top: 0, leading: MainScreenConstants.adaptiveValue(20), bottom: 0, trailing: MainScreenConstants.adaptiveValue(20)))
                }
                .listRowBackground(Color.clear)
                .listSectionSpacing(.custom(MainScreenConstants.adaptiveValue(12)))
                .listRowSeparator(.hidden)
                
                    AboutSection(viewModel: viewModel)
                    PersonalisationSection(viewModel: viewModel)
                    SupportSection(viewModel: viewModel)
                    LegalSection(viewModel: viewModel)
                    StatisticsSection(viewModel: viewModel)
                }
            .listStyle(.plain)
            .listSectionSpacing(.custom(MainScreenConstants.adaptiveValue(24)))
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
        }
        .preferredColorScheme(getColorScheme())
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $viewModel.showVersionSheet) {
            VersionSheet()
        }
        .sheet(isPresented: $viewModel.showContactMail) {
            MailComposer(
                toRecipients: ["info@gizatech.de"],
                subject: "Contact - Leben in Deutschland App",
                messageBody: ""
            )
        }
        .sheet(isPresented: $viewModel.showBugReportMail) {
            MailComposer(
                toRecipients: ["support@gizatech.de"],
                subject: "Bug Report - Leben in Deutschland App",
                messageBody: viewModel.getDeviceInfo()
            )
        }
        .overlay(
            Group {
                if viewModel.showUpdateAlert, let type = viewModel.updateAlertType {
                    switch type {
                    case .latest:
                        UpdateLatestDialog(
                            isPresented: viewModel.showUpdateAlert,
                            onDismiss: {
                                HapticManager.shared.lightImpact()
                                viewModel.dismissUpdateAlert()
                            }
                        )
                    case .available:
                        UpdateAvailableDialog(
                            isPresented: viewModel.showUpdateAlert,
                            onDismiss: {
                                HapticManager.shared.lightImpact()
                                viewModel.dismissUpdateAlert()
                            }
                        )
                    case .required:
                        UpdateRequiredDialog(
                            isPresented: viewModel.showUpdateAlert,
                            onDismiss: {
                                HapticManager.shared.lightImpact()
                                viewModel.dismissUpdateAlert()
                            }
                        )
                    }
                }
            }
        )
        .overlay(
            DeleteConfirmationDialog(
                isPresented: viewModel.showDeleteWarning,
                onCancel: {
                    HapticManager.shared.lightImpact()
                    viewModel.showDeleteWarning = false
                },
                onConfirm: {
                    viewModel.confirmDelete {
                        // Restart app after deletion
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            exit(0)
                        }
                    }
                }
            )
        )
    }
    
    // Convert saved appearance to ColorScheme
    private func getColorScheme() -> ColorScheme? {
        switch appAppearance {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil // System default
        }
    }
}

// MARK: - Previews
#Preview {
    SettingsView()
        .environmentObject(StateManager())
        .environmentObject(LanguageManager())
}

// MARK: - Settings Header
private struct SettingsHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: MainScreenConstants.adaptiveValue(8)) {
            Text("settings_title".localized)
                .font(.system(size: MainScreenConstants.adaptiveValue(36), weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)
            
            Text("settings_subtitle".localized)
                .font(.system(.body, design: .rounded).weight(.medium))
                .foregroundStyle(.secondary)
                .accessibilityLabel("settings_subtitle".localized)
        }
    }
}

// MARK: - Settings Background
private struct SettingsBackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.accentColor.opacity(0.22),
                Color(.systemBackground).opacity(0.95)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .background(Color(.systemBackground))
    }
}
