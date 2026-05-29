import SwiftUI

// MARK: - Onboarding Date Selection Content Component
struct OnboardingDateSelectionContentComponent: View {
    @Binding var selectedDate: Date?
    let onSelectDate: () -> Void
    let onDontKnow: () -> Void
    let hasSelectedDate: Bool
    let hasSelectedDontKnow: Bool
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    var body: some View {
        VStack(spacing: OnboardingConstants.defaultSpacing) {
            QuizAnswerOptionButton(
                primaryText: selectedDate != nil ? formatDate(selectedDate!) : "SELECT_DATE".localized,
                state: hasSelectedDate ? .selected : .neutral,
                suppressGlow: true,
                action: onSelectDate
            )
            
            QuizAnswerOptionButton(
                primaryText: "dont_know_date".localized,
                state: hasSelectedDontKnow ? .selected : .neutral,
                suppressGlow: true,
                action: onDontKnow
            )
        }
        .transaction { t in t.animation = nil }
        .frame(width: layoutMetrics.screenWidth * OnboardingConstants.buttonWidthRatio)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 16)
        .padding(.horizontal, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = languageManager.currentLocale
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
