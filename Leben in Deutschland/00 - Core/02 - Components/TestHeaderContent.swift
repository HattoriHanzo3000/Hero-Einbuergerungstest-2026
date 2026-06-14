//
//  TestHeaderContent.swift
//  Leben in Deutschland
//
//  Message formatting for Home header: test date and readiness score.
//

import SwiftUI

// MARK: - Readiness Message Helper
/// Formats the eagle-stage readiness message used in Progress and Home headers.
enum ReadinessMessageHelper {
    /// Returns localized eagle_desc message for the given readiness percentage.
    static func message(readinessPercentage: Int, languageCode: String) -> String {
        let key = eagleDescKey(for: readinessPercentage)
        let localized = key.localized
        let locale = Locale(identifier: languageCode)
        return String(format: localized, locale: locale, readinessPercentage)
    }

    private static func eagleDescKey(for percentage: Int) -> String {
        switch percentage {
        case 0..<5: return "eagle_desc_egg"
        case 5..<17: return "eagle_desc_chick"
        case 17..<34: return "eagle_desc_young"
        case 34..<51: return "eagle_desc_growing"
        case 51..<84: return "eagle_desc_wise"
        default: return "eagle_desc_master"
        }
    }
}

// MARK: - Test Date Message Helper
/// Shared logic for formatting test date message. Used by HomeHeader.
enum TestDateMessageHelper {
    static func message(for date: Date?) -> String {
        guard let date = date else { return "test_header_set_date_prompt".localized }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let testDay = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: today, to: testDay).day ?? 0

        guard days >= 0 else { return "test_header_set_date_prompt".localized }
        guard days <= 365 else { return "test_header_set_date_prompt".localized }

        if days == 0 {
            return "perfect_test_today".localized
        }
        return "perfect_days_remaining".localizedPlural(
            days,
            languageCode: LanguageManager.currentAppLanguageCode
        )
    }
}
