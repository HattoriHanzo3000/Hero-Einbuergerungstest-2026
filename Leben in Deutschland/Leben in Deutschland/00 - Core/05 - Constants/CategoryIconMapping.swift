//
//  CategoryIconMapping.swift
//  Leben in Deutschland
//
//  Maps localized category names to SF Symbol icons.
//  Centralized to avoid hardcoded switches in views.
//

import Foundation

/// Provides SF Symbol icon names for categories by localized name.
enum CategoryIconMapping {
    /// All localized names per category, mapped to icon.
    private static let mapping: [Set<String>: String] = [
        ["Law and Constitution", "Recht und Verfassung", "Право и Конституция", "Право та Конституція"]: "building.columns.fill",
        ["Family and Education", "Familie und Bildung", "Семья и образование", "Освіта та Сім'я"]: "figure.2.and.child.holdinghands",
        ["State", "Staat", "Государство", "Держава"]: "flag.fill",
        ["Elections", "Wahlen", "Выборы", "Вибори"]: "checkmark.square.fill",
        ["State Institutions", "Staatsorgane", "Гос Органы", "Державні органи"]: "building.2.fill",
        ["Economy and Work", "Wirtschaft und Arbeit", "Экономика и работа", "Робота та Економіка"]: "briefcase.fill",
        ["Society and Culture", "Gesellschaft und Kultur", "Общество и Культура", "Суспільство та Культура"]: "face.smiling.inverse",
        ["History", "Geschichte", "История", "Історія"]: "book.closed.fill",
        ["Europe", "Europa", "Европа", "Європа та ЄС"]: "eurosign",
        ["Federal States", "Bundesländer", "Федеральные земли", "Федеральні землі"]: "mappin.and.ellipse"
    ]
    
    /// Returns SF Symbol name for a category, or fallback icon if unknown.
    static func icon(for categoryName: String) -> String {
        for (names, icon) in mapping {
            if names.contains(categoryName) {
                return icon
            }
        }
        return "folder.fill"
    }
}
