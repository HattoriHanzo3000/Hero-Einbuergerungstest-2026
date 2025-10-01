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
    @StateObject private var appFlow = AppFlow()
    
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
                    // Replace with your real main view when ready
                    ContentView()
                }
            }
            // Inject shared dependencies
            .environmentObject(languageManager)
        }
    }
}

// MARK: - Tiny placeholder to keep you moving
private struct OnboardingPlaceholder: View {
    let title: String
    let buttonTitle: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text(title)
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Button(buttonTitle, action: action)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color(.systemGray6))
                .padding(.vertical, 14)
                .frame(maxWidth: 260)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor)
                )
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
