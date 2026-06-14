import Foundation
import SwiftUI
import Combine

// MARK: - Onboarding Date ViewModel
@MainActor
class OnboardingDateViewModel: ObservableObject {
    @Published var selectedDate: Date?
    @Published var hasSelectedDate: Bool = false
    @Published var hasSelectedDontKnow: Bool = false
    @Published var showDialog: Bool = false
    
    let languageManager: LanguageManager
    private let preferences: OnboardingPreferences
    private let onNext: (() -> Void)?
    private let onBack: (() -> Void)?
    
    init(languageManager: LanguageManager, preferences: OnboardingPreferences? = nil, onNext: (() -> Void)? = nil, onBack: (() -> Void)? = nil) {
        self.languageManager = languageManager
        self.preferences = preferences ?? OnboardingPreferences.shared
        self.onNext = onNext
        self.onBack = onBack
    }
    
    /// Header message key for simple (non-plural) onboarding copy.
    var dialogMessageKey: String {
        if hasSelectedDate, let date = selectedDate {
            let days = daysUntil(date)
            if days > 365 { return "onboarding_date_prompt" }
            if days == 0 { return "perfect_test_today" }
            return "onboarding_date_prompt"
        }
        if hasSelectedDontKnow { return "no_problem_later" }
        return "onboarding_date_prompt"
    }

    /// Preformatted header copy for plural day countdown (1–365 days).
    var dialogMessageText: String? {
        guard hasSelectedDate, let date = selectedDate else { return nil }
        let days = daysUntil(date)
        guard days >= 1, days <= 365 else { return nil }
        return "perfect_days_remaining".localizedPlural(
            days,
            languageCode: languageManager.currentAppLanguage
        )
    }

    var dialogHeaderId: String {
        if let text = dialogMessageText { return "days-\(text)" }
        return dialogMessageKey
    }
    
    func setupInitialState() {
        // Only restore when user had previously selected (returning from a later step)
        if let savedDate = preferences.testDate {
            selectedDate = savedDate
            hasSelectedDate = true
            hasSelectedDontKnow = false
        } else if preferences.testDateDontKnow {
            selectedDate = nil
            hasSelectedDate = false
            hasSelectedDontKnow = true
        } else {
            selectedDate = nil
            hasSelectedDate = false
            hasSelectedDontKnow = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + OnboardingConstants.dialogDelay) {
            self.showDialog = true
        }
    }
    
    func chooseDate(_ date: Date) {
        selectedDate = date
        hasSelectedDate = true
        hasSelectedDontKnow = false
        preferences.testDate = date
        preferences.testDateDontKnow = false
    }
    
    func chooseDontKnow() {
        selectedDate = nil
        hasSelectedDate = false
        hasSelectedDontKnow = true
        preferences.testDate = nil
        preferences.testDateDontKnow = true
    }
    
    func proceedToNext() { onNext?() }
    func goBack() { onBack?() }

    // MARK: - Helpers
    private func daysUntil(_ date: Date) -> Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }
}
