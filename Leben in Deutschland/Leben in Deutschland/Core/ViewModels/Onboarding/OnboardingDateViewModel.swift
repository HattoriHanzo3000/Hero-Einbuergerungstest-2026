import Foundation
import SwiftUI
import Combine

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
        guard let date = selectedDate, hasSelectedDate else {
            return "test_date_selection_title"
        }
        let days = daysUntil(date)
        if days <= 0 { return "perfect_test_today" }
        if days == 1 { return "perfect_day_left" }
        return "perfect_days_left"
    }
    
    var dialogParameters: [String]? {
        guard let date = selectedDate, hasSelectedDate else { return nil }
        let days = max(0, daysUntil(date))
        return [String(days)]
    }
    
    func setupInitialState() {
        if let saved = preferences.testDate {
            selectedDate = saved
            hasSelectedDate = true
            hasSelectedDontKnow = false
        } else if preferences.testDateDontKnow {
            hasSelectedDate = false
            hasSelectedDontKnow = true
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


