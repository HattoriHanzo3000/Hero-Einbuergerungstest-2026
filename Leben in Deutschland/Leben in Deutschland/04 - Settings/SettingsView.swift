import SwiftUI

// Main Settings View
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SettingsViewModel()
    @AppStorage("app_appearance") private var appAppearance: String = "system"
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: MainScreenConstants.adaptiveValue(28)) {
                // Header island
                SetupHeader(
                    title: "settings_title".localized,
                    onDismiss: {
                        HapticManager.shared.lightImpact()
                        dismiss()
                    }
                )
                
                // Content sections
                VStack(spacing: MainScreenConstants.adaptiveValue(28)) {
                    // About Section
                    AboutSection(viewModel: viewModel)
                    
                    // Personalisation Section
                    PersonalisationSection(viewModel: viewModel)
                    
                    // Support Section
                    SupportSection(viewModel: viewModel)
                    
                    // Legal Section
                    LegalSection(viewModel: viewModel)
                    
                    // Statistics Section
                    StatisticsSection(viewModel: viewModel)
                }
                .padding(.horizontal, MainScreenConstants.adaptiveValue(24))
                .padding(.bottom, MainScreenConstants.adaptiveValue(24))
            }
            .padding(.top, MainScreenConstants.adaptiveValue(16))
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                Text("Ad Placeholder")
                    .font(.system(.caption, design: .rounded).weight(.medium))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: MainScreenConstants.adaptiveValue(60))
            .padding(.horizontal, MainScreenConstants.adaptiveValue(16))
            .padding(.bottom, MainScreenConstants.adaptiveValue(16))
            .background(
                RoundedRectangle(cornerRadius: MainScreenConstants.adaptiveValue(16))
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [6, 3]))
                    .foregroundColor(Color.green.opacity(0.7))
            )
            .background(Color(.systemBackground).ignoresSafeArea())
        }
        .preferredColorScheme(getColorScheme())
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
