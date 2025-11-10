//
//  Leben_in_DeutschlandApp.swift
//  Leben in Deutschland
//
//  Created by Ildar Gizatullin on 23.09.25.
//

import SwiftUI
import Combine

@main
struct Leben_in_DeutschlandApp: App {
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var soundManager = SoundManager.shared
    @StateObject private var appFlow = AppFlow()
    @AppStorage("app_appearance") private var appAppearance: String = "system"
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appFlow.stage {
                case .startAnimation:
                    OnboardingStartView {
                        // After the intro video, start onboarding
                        appFlow.stage = .onboardingLanguage
                    }
                case .onboardingLanguage:
                    OnboardingLanguageView(
                        viewModel: OnboardingLanguageViewModel(
                            languageManager: languageManager,
                            onNext: { appFlow.stage = .onboardingTranslation }
                        )
                    )
                case .onboardingTranslation:
                    OnboardingTranslationView(
                        viewModel: OnboardingTranslationViewModel(
                            languageManager: languageManager,
                            onNext: { appFlow.stage = .onboardingState },
                            onBack: { appFlow.stage = .onboardingLanguage }
                        )
                    )
                case .onboardingState:
                    OnboardingStateView(
                        viewModel: OnboardingStateViewModel(
                            languageManager: languageManager,
                            onNext: { appFlow.stage = .onboardingDate },
                            onBack: { appFlow.stage = .onboardingTranslation }
                        )
                    )
                case .onboardingDate:
                    OnboardingDateView(
                        viewModel: OnboardingDateViewModel(
                            languageManager: languageManager,
                            onNext: { appFlow.stage = .onboardingSplash },
                            onBack: { appFlow.stage = .onboardingState }
                        )
                    )
                case .onboardingSplash:
                    OnboardingSplashView(onFinish: { appFlow.stage = .main })
                case .main:
                    MainTabView()
                }
            }
            // Inject shared dependencies
            .environmentObject(languageManager)
            .environmentObject(soundManager)
            .environmentObject(StateManager())
            // Apply appearance mode - updates immediately when @AppStorage changes
            .preferredColorScheme(getColorScheme())
            // Limit Dynamic Type scale up to XXXLarge to preserve layout integrity
            .dynamicTypeSize(.xSmall ... .xxxLarge)
        }
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
