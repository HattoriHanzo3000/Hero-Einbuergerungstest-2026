import SwiftUI

// MARK: - Date Selection Content
struct DateSelectionContent: View {
    @Binding var selectedDate: Date?
    let onSelectDate: () -> Void
    let onDontKnow: () -> Void
    let hasSelectedDate: Bool
    let hasSelectedDontKnow: Bool
    @Binding var showDialog: Bool
    
    var body: some View {
        VStack(spacing: OnboardingConstants.defaultSpacing) {
            Button(action: onSelectDate) {
                Text(selectedDate != nil ? formatDate(selectedDate!) : "SELECT_DATE".localized)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(hasSelectedDate ? .white : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(hasSelectedDate ? Color("Fill") : Color(.unselected))
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: onDontKnow) {
                Text("dont_know_date".localized)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(hasSelectedDontKnow ? .white : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(hasSelectedDontKnow ? Color("Fill") : Color(.unselected))
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(width: OnboardingConstants.getButtonWidth())
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 16)
        .padding(.horizontal, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let code = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        let locale: Locale = {
            switch code { case "ru": return Locale(identifier: "ru_RU"); case "de": return Locale(identifier: "de_DE"); case "uk": return Locale(identifier: "uk_UA"); default: return Locale(identifier: "en_US") }
        }()
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}


