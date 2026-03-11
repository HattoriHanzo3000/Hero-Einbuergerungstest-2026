//
//  HomeLearnOptionsSection.swift
//  Leben in Deutschland
//
//  Learn section with 3 buttons: Spaced Repetition, Learn by Topics, Favorites
//

import SwiftUI

struct HomeLearnOptionsSection: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    @Environment(AppRouter.self) private var router

    var body: some View {
        SectionContainer(title: "home_learn_section_title", spacing: 18) {
            VStack(spacing: layoutMetrics.adaptive(16)) {
                Button {
                    HapticManager.shared.lightImpact()
                    router.push(.allQuestions)
                } label: {
                    LearnButtonContent(
                        icon: "book.fill",
                        title: "home_learn_all_questions",
                        subtitle: "home_learn_all_questions_subtitle",
                        color: .black,
                        iconBackgroundColor: LearnButtonContent.germanFlagGold,
                        iconSplitColors: LearnButtonContent.germanFlagBookSplit
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
                    handleTestSimulationTap()
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
        }
        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
        .id(languageManager.currentAppLanguage)
    }

    private func handleTestSimulationTap() {
        if subscriptionManager.isPremium {
            router.push(.testCountdown)
            return
        }
        let used = UserDefaults.standard.integer(forKey: UserDefaultsKeys.testSimulationFreeSessionsUsed)
        if used < 3 {
            UserDefaults.standard.set(used + 1, forKey: UserDefaultsKeys.testSimulationFreeSessionsUsed)
            router.push(.testCountdown)
        } else {
            subscriptionManager.gateFeature(placement: "test_simulation") {
                router.push(.testCountdown)
            }
        }
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
