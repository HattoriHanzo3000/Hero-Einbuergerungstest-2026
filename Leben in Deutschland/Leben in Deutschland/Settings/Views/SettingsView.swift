import SwiftUI

// Main Settings View
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SettingsViewModel()
    @AppStorage("app_appearance") private var appAppearance: String = "system"
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            SetupHeader(
                title: "settings_title".localized,
                onDismiss: {
                    HapticManager.shared.lightImpact()
                    dismiss()
                }
            )
            
            // Content area
            ScrollView {
                VStack(spacing: 28) {
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
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
            .background(Color(.systemBackground))
        }
        .id(appAppearance) // Force view refresh when appearance changes
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
            UpdateAlertDialog(
                isPresented: viewModel.showUpdateAlert,
                title: viewModel.updateAlertTitle,
                message: viewModel.updateAlertMessage,
                onDismiss: {
                    HapticManager.shared.lightImpact()
                    viewModel.showUpdateAlert = false
                }
            )
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
        .environment(\.dynamicTypeSize, .large)
}

#Preview("Medium") {
    SettingsView()
        .environmentObject(StateManager())
        .environmentObject(LanguageManager())
        .environment(\.dynamicTypeSize, .medium)
}

#Preview("xxxLarge") {
    SettingsView()
        .environmentObject(StateManager())
        .environmentObject(LanguageManager())
        .environment(\.dynamicTypeSize, .xxxLarge)
}
