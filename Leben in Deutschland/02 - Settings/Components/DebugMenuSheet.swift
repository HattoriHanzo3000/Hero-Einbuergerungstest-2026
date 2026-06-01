//
//  DebugMenuSheet.swift
//  Leben in Deutschland
//
//  Debug-only developer menu for testing pro/readiness states and test result screens.
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
    @State private var showEagleLevelUp = false
    @State private var showLanguageScreenshot = false
    @State private var testSessionScreenshotPresentation: DebugTestSessionPreviewPresentation?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Simulate Pro", selection: Binding(
                        get: {
                            switch overrides.simulatePro {
                            case nil: return "real"
                            case true: return "pro"
                            case false: return "free"
                            }
                        },
                        set: { value in
                            switch value {
                            case "real": overrides.simulatePro = nil
                            case "pro": overrides.simulatePro = true
                            case "free": overrides.simulatePro = false
                            default: overrides.simulatePro = nil
                            }
                        }
                    )) {
                        Text("Use real").tag("real")
                        Text("Pro").tag("pro")
                        Text("Free").tag("free")
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Pro Status")
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
                    Button("Preview Test Screenshot (Q8 · 234)") {
                        testSessionScreenshotPresentation = DebugTestSessionPreviewPresentation()
                    }
                    Button("Preview Test Passed") {
                        showTestResultPassed = true
                    }
                    Button("Preview Test Failed") {
                        showTestResultFailed = true
                    }
                } header: {
                    Text("Test Simulation")
                } footer: {
                    Text("Screenshot: question 8 of 33, catalog #234 (German text), UI in app language, circles 1–7 answered, timer 58:28.")
                }

                Section {
                    Button("Clear All Overrides", role: .destructive) {
                        overrides.clearAll()
                    }
                }

                Section {
                    Button("Preview Eagle Level Up (100%)") {
                        showEagleLevelUp = true
                    }
                } header: {
                    Text("Eagle Level Up")
                } footer: {
                    Text("Directly previews the 100% (master) splash screen for UI testing.")
                }

                Section {
                    Button("Preview Language Screenshot") {
                        showLanguageScreenshot = true
                    }
                } header: {
                    Text("App Store Screenshots")
                } footer: {
                    Text("Marketing layout for the languages screenshot. Switch app language in Settings before capturing.")
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
            .fullScreenCover(isPresented: $showTestResultPassed) {
                testResultSheet(passed: true) { showTestResultPassed = false }
            }
            .fullScreenCover(isPresented: $showTestResultFailed) {
                testResultSheet(passed: false) { showTestResultFailed = false }
            }
            .fullScreenCover(isPresented: $showEagleLevelUp) {
                EagleLevelUpView(
                    stage: .master,
                    readinessPercentage: 100,
                    onDismiss: { showEagleLevelUp = false }
                )
                .environmentObject(languageManager)
                .layoutMetrics(layoutMetrics)
            }
            .fullScreenCover(isPresented: $showLanguageScreenshot) {
                LanguageScreenshotPreviewView(onDismiss: { showLanguageScreenshot = false })
                    .layoutMetrics(layoutMetrics)
            }
            .fullScreenCover(item: $testSessionScreenshotPresentation) { _ in
                DebugTestSessionPreviewView(onDismiss: {
                    testSessionScreenshotPresentation = nil
                })
                .environmentObject(languageManager)
                .environmentObject(favoritesManager)
                .environmentObject(SubscriptionManager.shared)
                .layoutMetrics(layoutMetrics)
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
        }
    }
}
#endif
