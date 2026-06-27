//
//  Leben_in_DeutschlandApp.swift
//  Leben in Deutschland
//
//  Created by Ildar Gizatullin on 23.09.25.
//

import SwiftUI
import SwiftData
import UIKit
import RevenueCat

@main
struct Leben_in_DeutschlandApp: App {
    @StateObject private var languageManager: LanguageManager
    @StateObject private var soundManager: SoundManager
    @StateObject private var appFlow: AppFlow
    @StateObject private var stateManager: StateManager
    @AppStorage(UserDefaultsKeys.appearance) private var appAppearance: String = "system"

    private let sharedModelContainer: ModelContainer

    init() {
#if DEBUG
        LaunchConfiguration.applyIfNeeded()
#endif
        _languageManager = StateObject(wrappedValue: LanguageManager())
        _soundManager = StateObject(wrappedValue: SoundManager.shared)
        _appFlow = StateObject(wrappedValue: AppFlow())
        _stateManager = StateObject(wrappedValue: StateManager.shared)

        let revenueCatAPIKey = AppConfiguration.revenueCatAPIKey
        if !revenueCatAPIKey.isEmpty {
            Purchases.configure(withAPIKey: revenueCatAPIKey)
        } else {
            assertionFailure("RevenueCat API key is not configured.")
        }

        do {
            sharedModelContainer = try SwiftDataModelContainerFactory.makeSharedContainer()
        } catch {
            fatalError("Could not create ModelContainer: \(error.localizedDescription)")
        }

        recordFirstLaunchIfNeeded()
        configureTabBarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { proxy in
                Group {
                    switch appFlow.stage {
                    case .startAnimation:
                        WelcomeVideoView {
                            // After welcome video, start onboarding — clear both storage layers
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
                                onNext: {
                                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                                    appFlow.stage = .main
                                },
                                onBack: { appFlow.stage = .onboardingState }
                            )
                        )
                    case .main:
                        MainView()
                    }
                }
                .layoutMetrics(LayoutMetrics.make(for: proxy.size))
                // Inject shared dependencies
                .environmentObject(languageManager)
                .environmentObject(soundManager)
                .environmentObject(appFlow)
                .environmentObject(stateManager)
                .environmentObject(FavoritesManager.shared)
                .environmentObject(SubscriptionManager.shared)
                .environmentObject(OnboardingPreferences.shared)
                // Apply appearance mode - updates immediately when @AppStorage changes
                .preferredColorScheme(getColorScheme())
                .background(Color("LaunchScreenBackground").ignoresSafeArea())
            }
        }
        .modelContainer(sharedModelContainer)
    }
    
    /// Records first launch date for 3-day Launch Offer. Called once per install.
    private func recordFirstLaunchIfNeeded() {
        if UserDefaults.standard.object(forKey: UserDefaultsKeys.firstLaunchDate) == nil {
            UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.firstLaunchDate)
        }
    }

    /// Tab bar: on iOS 18+ only tint (system provides floating style); on iOS 17 use default background.
    private func configureTabBarAppearance() {
        let accentColor = UIColor(named: "AccentColor") ?? .systemBlue
        UITabBar.appearance().tintColor = accentColor
        UITabBar.appearance().unselectedItemTintColor = .tertiaryLabel
        guard ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 18 else { return }
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        // Set selected state on the appearance so it isn’t overridden by SwiftUI/accent.
        appearance.stackedLayoutAppearance.normal.iconColor = .tertiaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.tertiaryLabel]
        appearance.stackedLayoutAppearance.selected.iconColor = accentColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: accentColor]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
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
