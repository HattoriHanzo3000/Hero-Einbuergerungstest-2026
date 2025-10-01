import Foundation
import SwiftUI
import Combine

// MARK: - Onboarding Date ViewModel
class OnboardingDateViewModel: ObservableObject {
    @Published var selectedDate: Date?
    @Published var hasSelectedDate: Bool = false
    @Published var hasSelectedDontKnow: Bool = false
    @Published var showDialog: Bool = false
    
    let languageManager: LanguageManager
    private let preferences: OnboardingPreferences
    private let onNext: () -> Void
    private let onBack: () -> Void
    
    init(languageManager: LanguageManager, preferences: OnboardingPreferences = .shared, onNext: @escaping () -> Void = {}, onBack: @escaping () -> Void = {}) {
        self.languageManager = languageManager
        self.preferences = preferences
        self.onNext = onNext
        self.onBack = onBack
    }
    
    // MARK: - Lifecycle
    func setupInitialState() {
        if let saved = UserDefaults.standard.string(forKey: "testDate"),
           let date = ISO8601DateFormatter().date(from: saved) {
            selectedDate = date
            hasSelectedDate = true
            hasSelectedDontKnow = false
        } else if preferences.hasLaunchedBefore && preferences.testDateDontKnow {
            hasSelectedDontKnow = true
            hasSelectedDate = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + OnboardingConstants.dialogDelay) {
            self.showDialog = true
        }
    }
    
    // MARK: - Actions
    func chooseDate(_ date: Date) {
        HapticManager.shared.lightImpact()
        selectedDate = date
        hasSelectedDate = true
        hasSelectedDontKnow = false
    }
    
    func chooseDontKnow() {
        HapticManager.shared.lightImpact()
        hasSelectedDontKnow = true
        hasSelectedDate = false
        selectedDate = nil
        preferences.testDateDontKnow = true
    }
    
    func proceedToNext() {
        guard hasSelectedDate || hasSelectedDontKnow else { return }
        if hasSelectedDate, let date = selectedDate {
            let iso = ISO8601DateFormatter().string(from: date)
            UserDefaults.standard.set(iso, forKey: "testDate")
            preferences.testDateDontKnow = false
        } else {
            UserDefaults.standard.removeObject(forKey: "testDate")
            preferences.testDateDontKnow = true
        }
        onNext()
    }
    
    func goBack() {
        onBack()
    }
    
    // MARK: - Dialog Message Key (matches old logic keys)
    var dialogMessageKey: String {
        if hasSelectedDate, let date = selectedDate {
            // Show days until test
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let testDate = calendar.startOfDay(for: date)
            let daysUntilTest = calendar.dateComponents([.day], from: today, to: testDate).day ?? 0
            
            if daysUntilTest == 0 {
                return "perfect_test_today"
            } else {
                // Handle language-specific pluralization
                let localizedKey = getDayKey(for: daysUntilTest)
                return localizedKey
            }
        } else if hasSelectedDontKnow {
            return "no_problem_later"
        } else {
            return "test_date_selection_title"
        }
    }
    
    var dialogParameters: [String] {
        if hasSelectedDate, let date = selectedDate {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let testDate = calendar.startOfDay(for: date)
            let daysUntilTest = calendar.dateComponents([.day], from: today, to: testDate).day ?? 0
            
            if daysUntilTest > 0 {
                return ["\(daysUntilTest)"]
            }
        }
        return []
    }
    
    // MARK: - Helper Functions (copied from old project)
    
    // Helper function for language-specific day pluralization
    private func getDayKey(for days: Int) -> String {
        switch languageManager.currentAppLanguage {
        case "ru":
            // Russian pluralization rules
            let lastDigit = days % 10
            let lastTwoDigits = days % 100
            
            // Special cases for 11-14
            if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
                return "perfect_days_left" // days
            }
            
            // Check last digit
            switch lastDigit {
            case 1:
                return "perfect_day_left" // day
            case 2, 3, 4:
                return "perfect_days_left_2_4" // days
            default:
                return "perfect_days_left" // days
            }
        case "de":
            // German pluralization rules (simpler)
            if days == 1 {
                return "perfect_day_left" // Tag
            } else {
                return "perfect_days_left" // Tage
            }
        case "en":
            // English pluralization rules
            if days == 1 {
                return "perfect_day_left" // day
            } else {
                return "perfect_days_left" // days
            }
        case "uk":
            // Ukrainian pluralization rules (similar to Russian)
            let lastDigit = days % 10
            let lastTwoDigits = days % 100
            
            // Special cases for 11-14
            if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
                return "perfect_days_left" // days
            }
            
            // Check last digit
            switch lastDigit {
            case 1:
                return "perfect_day_left" // day
            case 2, 3, 4:
                return "perfect_days_left_2_4" // days
            default:
                return "perfect_days_left" // days
            }
        default:
            return "perfect_days_left"
        }
    }
}


