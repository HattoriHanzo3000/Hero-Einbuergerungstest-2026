//
//  LanguageViewModel.swift
//  Leben in Deutschland
//
//  Manages language selection logic
//

import Foundation
import Combine

// MARK: - Language ViewModel
@MainActor
class LanguageViewModel: ObservableObject {
    // MARK: - Data
    let languages = LanguageOptionModel.allLanguages
    
    // MARK: - Public Methods
    
    /// Handles app language selection
    func selectAppLanguage(_ code: String, languageManager: LanguageManager) {
        HapticManager.shared.lightImpact()
        languageManager.setAppLanguage(code)
        
        // Ensure translation language is different from app language
        if languageManager.currentTranslationLanguage == code {
            let fallback = ["de", "en", "ru", "uk"].first(where: { $0 != code }) ?? "en"
            languageManager.setTranslationLanguage(fallback)
        }
    }
    
    /// Handles translation language selection
    func selectTranslationLanguage(_ code: String, languageManager: LanguageManager) {
        HapticManager.shared.lightImpact()
        languageManager.setTranslationLanguage(code)
    }
}
