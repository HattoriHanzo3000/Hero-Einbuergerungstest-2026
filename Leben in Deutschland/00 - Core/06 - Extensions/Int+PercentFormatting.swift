//
//  Int+PercentFormatting.swift
//  Leben in Deutschland
//
//  Locale-aware percent strings for readiness scores (0–100).
//  Created: 14.06.26.
//

import Foundation

extension Int {
    /// Formats a 0–100 readiness value as a locale-aware percent string (e.g. "72%").
    func localizedReadinessPercent(languageCode: String) -> String {
        formatted(
            .percent
                .scale(1)
                .precision(.fractionLength(0))
                .locale(Locale(identifier: languageCode))
        )
    }

    static func localizedFullReadinessPercent(languageCode: String = LanguageManager.currentAppLanguageCode) -> String {
        100.localizedReadinessPercent(languageCode: languageCode)
    }

    /// Formats a negative discount for marketing copy (e.g. "-50%").
    static func localizedDiscountPercent(_ value: Int, languageCode: String = LanguageManager.currentAppLanguageCode) -> String {
        (-abs(value)).formatted(
            .percent
                .scale(1)
                .precision(.fractionLength(0))
                .locale(Locale(identifier: languageCode))
        )
    }
}

enum PaywallPercentFormatting {
    static let launchOfferDiscount = 50
    static let annualSavings = 37

    static func launchOfferBadgeText(languageCode: String = LanguageManager.currentAppLanguageCode) -> String {
        "launch_offer_badge".localizedFormat(
            Int.localizedDiscountPercent(launchOfferDiscount, languageCode: languageCode),
            languageCode: languageCode
        )
    }

    static func launchOfferLine2Text(languageCode: String = LanguageManager.currentAppLanguageCode) -> String {
        "launch_offer_line2".localizedFormat(
            Int.localizedDiscountPercent(launchOfferDiscount, languageCode: languageCode),
            languageCode: languageCode
        )
    }

    static func yearSavingsText(languageCode: String = LanguageManager.currentAppLanguageCode) -> String {
        "paywall_year_savings".localizedFormat(
            annualSavings.localizedReadinessPercent(languageCode: languageCode),
            languageCode: languageCode
        )
    }
}

enum ReadinessExplanationFormatter {
    static func fullMessage(totalQuestions: Int, languageCode: String) -> String {
        "progress_readiness_explanation_full".localizedFormat(
            Int.localizedFullReadinessPercent(languageCode: languageCode),
            totalQuestions,
            "home_learn_spaced_repetition".localized(for: languageCode),
            "test_simulation_title".localized(for: languageCode),
            languageCode: languageCode
        )
    }
}
