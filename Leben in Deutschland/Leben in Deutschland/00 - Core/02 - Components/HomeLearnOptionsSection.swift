//
//  HomeLearnOptionsSection.swift
//  Leben in Deutschland
//
//  Learn option buttons: All Questions, Learn by Topics, Smart Learning, Favorites, Test.
//

import SwiftUI

struct HomeLearnOptionsSection: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    @Environment(AppRouter.self) private var router

    @AppStorage(UserDefaultsKeys.spacedRepetitionDisclaimerDismissed) private var disclaimerDismissed = false

    var body: some View {
        VStack(spacing: layoutMetrics.adaptive(16)) {
            Button {
                HapticManager.shared.lightImpact()
                router.push(.allQuestions)
            } label: {
                LearnButtonContent(
                    icon: "book.fill",
                    title: "home_learn_all_questions",
                    subtitle: "home_learn_all_questions_subtitle",
                    color: Color("AppPurple")
                )
            }
            .buttonStyle(BouncyScaleButtonStyle())

            Button {
                HapticManager.shared.lightImpact()
                router.push(.categories)
            } label: {
                LearnButtonContent(
                    icon: "books.vertical.fill",
                    title: "home_learn_by_topics",
                    subtitle: "home_learn_by_topics_subtitle",
                    color: Color("AppCaribean")
                )
            }
            .buttonStyle(BouncyScaleButtonStyle())

            Button {
                HapticManager.shared.lightImpact()
                router.push(.spacedRepetition)
            } label: {
                LearnButtonContent(
                    icon: "arrow.triangle.2.circlepath",
                    title: "home_learn_spaced_repetition",
                    subtitle: "home_learn_spaced_repetition_subtitle",
                    color: Color("AppBlueLagoon"),
                    badgeText: disclaimerDismissed ? nil : "home_learn_recommended_badge"
                )
            }
            .buttonStyle(BouncyScaleButtonStyle())

            Button {
                HapticManager.shared.lightImpact()
                subscriptionManager.gateFeatureWithPreview(
                    placement: "favorites",
                    titleKey: "favorites_disclaimer_title",
                    messageKey: "favorites_disclaimer_message",
                    accentColorName: "AppPink",
                    handler: { router.push(.favorites) }
                )
            } label: {
                LearnButtonContent(
                    icon: "heart.fill",
                    title: "home_learn_favorites",
                    subtitle: "home_learn_favorites_subtitle",
                    color: Color("AppPink")
                )
            }
            .buttonStyle(BouncyScaleButtonStyle())

            Button {
                HapticManager.shared.lightImpact()
                subscriptionManager.gateFeatureWithPreview(
                    placement: "test_simulation",
                    titleKey: "test_simulation_disclaimer_title",
                    messageKey: "test_simulation_disclaimer_message",
                    accentColorName: "AppOrange",
                    handler: { router.push(.testCountdown) }
                )
            } label: {
                LearnButtonContent(
                    icon: "checkmark.seal",
                    title: "learn_option_test_title",
                    subtitle: "learn_option_test_subtitle",
                    color: Color("AppOrange")
                )
            }
            .buttonStyle(BouncyScaleButtonStyle())
            .accessibilityLabel("learn_option_test_title".localized)
            .accessibilityHint("learn_option_test_description".localized)
        }
        .id(languageManager.currentAppLanguage)
    }
}

// MARK: - Preview
#Preview {
    HomeLearnOptionsSection()
        .environment(AppRouter())
        .environmentObject(LanguageManager())
        .environmentObject(SubscriptionManager.shared)
        .padding()
        .background(Color(.systemBackground))
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
