//
//  HomeLearnOptionsSection.swift
//  Leben in Deutschland
//
//  Learn option buttons: All Questions, Spaced Repetition, Learn by Topics, Favorites, Test.
//

import SwiftUI

struct HomeLearnOptionsSection: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    @Environment(AppRouter.self) private var router

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
                subscriptionManager.gateFeature(placement: "spaced_repetition") {
                    router.push(.spacedRepetition)
                }
            } label: {
                LearnButtonContent(
                    icon: "arrow.triangle.2.circlepath",
                    title: "home_learn_spaced_repetition",
                    subtitle: "home_learn_spaced_repetition_subtitle",
                    color: Color("AppBlueLagoon")
                )
            }
            .buttonStyle(BouncyScaleButtonStyle())

            Button {
                HapticManager.shared.lightImpact()
                subscriptionManager.gateFeature(placement: "learn_by_topics") {
                    router.push(.categories)
                }
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
                subscriptionManager.gateFeature(placement: "favorites") {
                    router.push(.favorites)
                }
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
                subscriptionManager.gateFeature(placement: "test_simulation") {
                    router.push(.testCountdown)
                }
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
