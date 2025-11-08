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
    
    // MARK: - Dialog content for header
    var dialogMessageKey: String {
        if hasSelectedDate, let date = selectedDate {
            let days = daysUntil(date)
            if days > 365 {
                return "test_date_selection_title"
            }
            if days == 0 {
                return "perfect_test_today"
            } else if days == 1 {
                return "perfect_day_left"
            } else if days >= 2 && days <= 4 {
                return "perfect_days_left_2_4"
            } else {
                return "perfect_days_left"
            }
        } else if hasSelectedDontKnow {
            return "no_problem_later"
        }
        return "test_date_selection_title"
    }
    
    var dialogParameters: [String]? {
        guard let date = selectedDate, hasSelectedDate else { return nil }
        let days = max(0, daysUntil(date))
        guard days <= 365 else { return nil }
        return [String(days)]
    }
    
    func setupInitialState() {
        if let savedDate = preferences.testDate {
            selectedDate = savedDate
            hasSelectedDate = true
            hasSelectedDontKnow = false
        } else if preferences.testDateDontKnow {
            selectedDate = nil
            hasSelectedDate = false
            hasSelectedDontKnow = true
        }
        // Show dialog with delay
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
