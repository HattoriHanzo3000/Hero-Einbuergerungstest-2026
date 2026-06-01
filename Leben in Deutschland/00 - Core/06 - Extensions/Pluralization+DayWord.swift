//
//  Pluralization+DayWord.swift
//  Leben in Deutschland
//
//  Shared helper for localized plural word declension (Russian, German, etc.).
//

import Foundation

enum Pluralization {
    /// Returns the correct form of "day" for the given count in the current app language.
    /// Russian: 1 день, 2–4 дня, 5–20 дней, 21 день, 22–24 дня, 25–30 дней, 31 день...
    /// Turkish: same word "gün" is used with numerals in these UI phrases (e.g. "5 gün").
    static func localizedDayWord(for days: Int, languageCode: String = LanguageManager.currentAppLanguageCode) -> String {
        switch languageCode {
        case "de": return days == 1 ? "Tag" : "Tage"
        case "tr": return "gün"
        case "ru":
            return russianPluralForm(
                count: days,
                one: "день",
                few: "дня",
                many: "дней"
            )
        default: return days == 1 ? "day" : "days"
        }
    }

    /// Returns the correct form of "result" for search result counts.
    /// Russian: 1 результат, 2–4 результата, 5–20 результатов, 21 результат...
    static func localizedSearchResultsWord(
        for count: Int,
        languageCode: String = LanguageManager.currentAppLanguageCode
    ) -> String {
        switch languageCode {
        case "de": return count == 1 ? "Ergebnis" : "Ergebnisse"
        case "tr": return "sonuç"
        case "ru":
            return russianPluralForm(
                count: count,
                one: "результат",
                few: "результата",
                many: "результатов"
            )
        default: return count == 1 ? "result" : "results"
        }
    }

    private static func russianPluralForm(count: Int, one: String, few: String, many: String) -> String {
        let lastDigit = count % 10
        let lastTwo = count % 100
        if (11...14).contains(lastTwo) { return many }
        switch lastDigit {
        case 1: return one
        case 2, 3, 4: return few
        default: return many
        }
    }
}
