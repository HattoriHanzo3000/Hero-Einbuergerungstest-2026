//
//  DebugMenuSheet.swift
//  Leben in Deutschland
//
//  Debug-only developer menu for testing premium/readiness states and test result screens.
//  Only compiled in DEBUG builds.
//

#if DEBUG
import SwiftUI

struct DebugMenuSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var favoritesManager: FavoritesManager
    @ObservedObject private var overrides = DebugOverrides.shared

    @State private var showTestResultPassed = false
    @State private var showTestResultFailed = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Simulate Premium", selection: Binding(
                        get: {
                            switch overrides.simulatePremium {
                            case nil: return "real"
                            case true: return "premium"
                            case false: return "free"
                            }
                        },
                        set: { value in
                            switch value {
                            case "real": overrides.simulatePremium = nil
                            case "premium": overrides.simulatePremium = true
                            case "free": overrides.simulatePremium = false
                            default: overrides.simulatePremium = nil
                            }
                        }
                    )) {
                        Text("Use real").tag("real")
                        Text("Premium").tag("premium")
                        Text("Free").tag("free")
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Premium Status")
                }

                Section {
                    Picker("Readiness Override", selection: $overrides.readinessPercentOverride) {
                        Text("Use real").tag(0)
                        Text("10%").tag(10)
                        Text("30%").tag(30)
                        Text("50%").tag(50)
                        Text("76%").tag(76)
                        Text("80%").tag(80)
                        Text("100%").tag(100)
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Readiness %")
                } footer: {
                    Text("Uses diverse (familiar, reinforced, mastered, expert) presets. Overrides eagle message and progress rings.")
                }

                Section {
                    Button("Preview Test Passed") {
                        showTestResultPassed = true
                    }
                    Button("Preview Test Failed") {
                        showTestResultFailed = true
                    }
                } header: {
                    Text("Test Simulation Result")
                } footer: {
                    Text("Shows how the result screen looks when user passed or failed the test.")
                }

                Section {
                    Button("Clear All Overrides", role: .destructive) {
                        overrides.clearAll()
                    }
                }
            }
            .navigationTitle("Developer Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showTestResultPassed) {
                testResultSheet(passed: true) { showTestResultPassed = false }
            }
            .sheet(isPresented: $showTestResultFailed) {
                testResultSheet(passed: false) { showTestResultFailed = false }
            }
        }
    }

    private func testResultSheet(passed: Bool, onDismiss: @escaping () -> Void) -> some View {
        NavigationStack {
            TestResultsView(
                viewModel: DebugTestResultsHelper.makeMockResultsViewModel(passed: passed),
                onBackToMainMenu: onDismiss,
                onTryAgain: onDismiss
            )
            .environmentObject(languageManager)
            .environmentObject(favoritesManager)
            .environment(AppRouter())
            .layoutMetrics(layoutMetrics)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onDismiss)
                }
            }
        }
    }
}
#endif
