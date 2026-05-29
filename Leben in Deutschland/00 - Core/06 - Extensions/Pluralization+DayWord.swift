//
//  Pluralization+DayWord.swift
//  Leben in Deutschland
//
//  Shared helper for localized day word declension (Russian, German, etc.).
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
            let lastDigit = days % 10, lastTwo = days % 100
            if (11...14).contains(lastTwo) { return "дней" }
            switch lastDigit {
            case 1: return "день"
            case 2, 3, 4: return "дня"
            default: return "дней"
            }
        default: return days == 1 ? "day" : "days"
        }
    }
}
