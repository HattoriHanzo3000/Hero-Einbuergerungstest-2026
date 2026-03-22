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
    /// Turkish names match `content_tr.json` category fields (`Eyaletler`, etc.).
    private static let mapping: [Set<String>: String] = [
        ["Law and Constitution", "Recht und Verfassung", "Право и Конституция", "Право та Конституція", "Hukuk ve Anayasa"]: "building.columns.fill",
        ["Family and Education", "Familie und Bildung", "Семья и образование", "Освіта та Сім'я", "Aile ve Eğitim"]: "figure.2.and.child.holdinghands",
        ["State", "Staat", "Государство", "Держава", "Devlet"]: "flag.fill",
        ["Elections", "Wahlen", "Выборы", "Вибори", "Seçimler"]: "checkmark.square.fill",
        ["State Institutions", "Staatsorgane", "Гос Органы", "Державні органи", "Devlet Organları"]: "building.2.fill",
        ["Economy and Work", "Wirtschaft und Arbeit", "Экономика и работа", "Робота та Економіка", "Ekonomi ve Çalışma Hayatı"]: "briefcase.fill",
        ["Society and Culture", "Gesellschaft und Kultur", "Общество и Культура", "Суспільство та Культура", "Toplum ve Kültür"]: "face.smiling.inverse",
        ["History", "Geschichte", "История", "Історія", "Tarih"]: "book.closed.fill",
        ["Europe", "Europa", "Европа", "Європа та ЄС", "Avrupa"]: "eurosign",
        ["Federal States", "Bundesländer", "Федеральные земли", "Федеральні землі", "Eyaletler"]: "mappin.and.ellipse"
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
