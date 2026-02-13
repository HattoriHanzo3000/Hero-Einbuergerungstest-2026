//
//  TestHeaderContent.swift
//  Leben in Deutschland
//
//  Header card for the Test tab: mascot + test date message. Uses shared ScreenHeaderCard.
//

import SwiftUI

// MARK: - Test Header Content
struct TestHeaderContent: View {
    let readinessPercentage: Int
    @Binding var savedTestDate: Date?

    @EnvironmentObject private var premiumManager: PremiumManager

    private var testDateMessage: String {
        guard let date = savedTestDate else { return "test_header_set_date_prompt".localized }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let testDay = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: today, to: testDay).day ?? 0

        guard days >= 0 else { return "test_header_set_date_prompt".localized }
        guard days <= 365 else { return "test_header_set_date_prompt".localized }

        if days == 0 {
            return "perfect_test_today".localized
        }
        let key: String
        if days == 1 {
            key = "perfect_day_left"
        } else if days >= 2 && days <= 4 {
            key = "perfect_days_left_2_4"
        } else {
            key = "perfect_days_left"
        }
        let dayWord = Pluralization.localizedDayWord(for: days, languageCode: LanguageManager.currentAppLanguageCode)
        return String(format: key.localized, days, dayWord)
    }

    var body: some View {
        ScreenHeaderCard(
            readinessPercentage: readinessPercentage,
            onPremiumTap: { premiumManager.presentPaywall() },
            autoPlayInterval: 60,
            content: .message(testDateMessage)
        )
    }
}

// MARK: - Preview
#Preview {
    TestHeaderContent(
        readinessPercentage: 72,
        savedTestDate: .constant(Date().addingTimeInterval(14 * 86400))
    )
    .environmentObject(LanguageManager())
    .environmentObject(PremiumManager.shared)
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
