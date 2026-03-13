//
//  TestCountdownView.swift
//  Leben in Deutschland
//
//  Full-screen white countdown (3, 2, 1) shown before the test session starts.
//

import SwiftUI

// MARK: - Test Countdown View
/// Presents a system-style white screen with a 3–2–1 countdown, then calls onComplete.
struct TestCountdownView: View {
    var onComplete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var stateManager: StateManager

    @AppStorage(UserDefaultsKeys.testSimulationDisclaimerDismissed) private var disclaimerDismissed = false
    @State private var showDisclaimer = false
    @State private var doNotShowAgain = false
    @State private var countdownStarted = false

    @State private var count: Int = 3
    @State private var isVisible = false

    private let countdownInterval: TimeInterval = 1.0
    private let contentService = ContentService.shared

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            if count > 0 {
                Text("\(count)")
                    .font(.system(size: layoutMetrics.adaptive(120), weight: .bold).width(.expanded))
                    .foregroundColor(Color("AppOrange"))
                    .scaleEffect(isVisible ? 1.0 : 0.3)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .animation(.easeOut(duration: 0.25), value: isVisible)
                    .animation(.easeOut(duration: 0.25), value: count)
            }
        }
        .navigationBarHidden(true)
        .hidesTabBar()
        .tabBarHidden(true)
        .onAppear {
            preloadTestContent()
            if disclaimerDismissed {
                startCountdown()
            } else {
                showDisclaimer = true
            }
        }
        .onChange(of: showDisclaimer) { _, isShowing in
            if !isShowing, !countdownStarted {
                startCountdown()
            }
        }
        .sheet(isPresented: $showDisclaimer) {
            LearnModeDisclaimerSheet(
                titleKey: "test_simulation_disclaimer_title",
                messageKey: "test_simulation_disclaimer_message",
                accentColor: Color("AppOrange"),
                doNotShowAgain: $doNotShowAgain,
                onDismiss: {
                    if doNotShowAgain {
                        disclaimerDismissed = true
                    }
                    showDisclaimer = false
                }
            )
            .environmentObject(languageManager)
            .environment(\.layoutMetrics, layoutMetrics)
        }
        .onChange(of: count) { _, newCount in
            guard newCount > 0 else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    onComplete()
                }
                return
            }
            isVisible = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isVisible = true
            }
        }
    }

    private func startCountdown() {
        countdownStarted = true
        isVisible = true
        scheduleCountdown()
    }

    private func scheduleCountdown() {
        DispatchQueue.main.asyncAfter(deadline: .now() + countdownInterval) {
            if count > 0 {
                count -= 1
                if count > 0 {
                    scheduleCountdown()
                }
            }
        }
    }
    
    /// Preload test content during countdown to avoid loading screen flash
    private func preloadTestContent() {
        Task {
            // Ensure content is loaded (including question images)
            if contentService.categories.isEmpty || contentService.isLoading {
                await contentService.loadContent(for: languageManager.currentAppLanguage)
                await HintService.shared.loadHints(for: languageManager.currentAppLanguage)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    TestCountdownView(onComplete: {})
        .environmentObject(LanguageManager())
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
