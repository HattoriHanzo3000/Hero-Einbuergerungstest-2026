//
//  LanguageOptionModel.swift
//  Leben in Deutschland
//
//  Model representing a language option
//

import Foundation

// MARK: - Language Option Model
struct LanguageOptionModel: Identifiable, Equatable {
    let id = UUID()
    let code: String
    let name: String
    
    // MARK: - All Available Languages
    static let allLanguages: [LanguageOptionModel] = [
        LanguageOptionModel(code: "en", name: "English"),
        LanguageOptionModel(code: "de", name: "Deutsch"),
        LanguageOptionModel(code: "ru", name: "Русский"),
        LanguageOptionModel(code: "uk", name: "Українська")
    ]
}
