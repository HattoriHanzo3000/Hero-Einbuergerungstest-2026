import SwiftUI

// MARK: - Onboarding Date Selection Content Component
struct OnboardingDateSelectionContentComponent: View {
    @Binding var selectedDate: Date?
    let onSelectDate: () -> Void
    let onDontKnow: () -> Void
    let hasSelectedDate: Bool
    let hasSelectedDontKnow: Bool
    @EnvironmentObject var languageManager: LanguageManager
    @State private var isSelectDatePressed = false
    @State private var isDontKnowPressed = false
    
    var body: some View {
        VStack(spacing: OnboardingConstants.defaultSpacing) {
            Button(action: onSelectDate) {
                Text(selectedDate != nil ? formatDate(selectedDate!) : "SELECT_DATE".localized)
                    .font(.body)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundColor(hasSelectedDate ? .white : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 56)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(hasSelectedDate ? Color.accentColor : Color("Unselected"))
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(isSelectDatePressed ? 0.98 : 1.0)
            .buttonPressAnimation(isPressed: $isSelectDatePressed)
            
            Button(action: onDontKnow) {
                Text("dont_know_date".localized)
                    .font(.body)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundColor(hasSelectedDontKnow ? .white : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 56)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(hasSelectedDontKnow ? Color.accentColor : Color("Unselected"))
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(isDontKnowPressed ? 0.98 : 1.0)
            .buttonPressAnimation(isPressed: $isDontKnowPressed)
        }
        .transaction { t in t.animation = nil }
        .frame(width: OnboardingConstants.getButtonWidth())
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
