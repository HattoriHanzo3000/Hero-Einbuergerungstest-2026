//
//  Leben_in_DeutschlandApp.swift
//  Leben in Deutschland
//
//  Created by Ildar Gizatullin on 23.09.25.
//

import SwiftUI
import Combine
import UIKit

@main
struct Leben_in_DeutschlandApp: App {
    @StateObject private var languageManager = LanguageManager()
    @StateObject private var soundManager = SoundManager.shared
    @StateObject private var appFlow = AppFlow()
    @StateObject private var stateManager = StateManager.shared
    @AppStorage(UserDefaultsKeys.appearance) private var appAppearance: String = "system"
    
    init() {
        configureTabBarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { proxy in
                Group {
                    switch appFlow.stage {
                    case .startAnimation:
                        OnboardingStartView {
                            // After the intro video, start onboarding — clear both storage layers
                            OnboardingPreferences.shared.clearOnboardingSelections()
                            stateManager.clearSelectedState()
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
                                stateManager: stateManager,
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
                        TabBarView()
                    }
                }
                .layoutMetrics(LayoutMetrics.make(for: proxy.size))
                // Inject shared dependencies
                .environmentObject(languageManager)
                .environmentObject(soundManager)
                .environmentObject(appFlow)
                .environmentObject(stateManager)
                .environmentObject(FavoritesManager.shared)
                .environmentObject(PremiumManager.shared)
                // Apply appearance mode - updates immediately when @AppStorage changes
                .preferredColorScheme(getColorScheme())
            }
        }
    }
    
    /// Uses native tab bar appearance (translucent blur on iOS 17). Selected tab uses AccentColor.
    private func configureTabBarAppearance() {
        let accentColor = UIColor(named: "AccentColor") ?? .systemBlue
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        // Set selected state on the appearance so it isn’t overridden by SwiftUI/accent.
        appearance.stackedLayoutAppearance.selected.iconColor = accentColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: accentColor]
        appearance.inlineLayoutAppearance.selected.iconColor = accentColor
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: accentColor]
        appearance.compactInlineLayoutAppearance.selected.iconColor = accentColor
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: accentColor]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = accentColor
        UITabBar.appearance().unselectedItemTintColor = .tertiaryLabel
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
