import SwiftUI

// MARK: - Main Header Content
struct MainHeaderContent: View {
    @EnvironmentObject var stateManager: StateManager
    @Binding var showDialog: Bool
    @Binding var savedTestDate: Date?
    let onStateButtonTapped: () -> Void
    @State private var isStateButtonPressed = false
    private let debugBordersEnabled = false
    
    // Adaptive layout metrics
    private var standardPadding: CGFloat { MainScreenConstants.adaptiveValue(16) }
    private var containerCornerRadius: CGFloat { MainScreenConstants.adaptiveValue(28) }
    private var headerSpacing: CGFloat { MainScreenConstants.adaptiveValue(10) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: headerSpacing) {
            if let selectedState = stateManager.selectedState {
                VStack(alignment: .leading, spacing: MainScreenConstants.adaptiveValue(4)) {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        onStateButtonTapped()
                    }) {
                        Text(getLocalizedStateName(selectedState))
                            .font(.title2.bold())
                            .fontDesign(.rounded)
                            .foregroundColor(Color(.systemGray6))
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .scaleEffect(isStateButtonPressed ? 0.97 : 1.0)
                    .animation(.easeInOut(duration: 0.08), value: isStateButtonPressed)
                    .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                        isStateButtonPressed = pressing
                    }, perform: {})
                    .accessibilityLabel("Federal State")
                    .accessibilityValue(getLocalizedStateName(selectedState))
                    .accessibilityHint("Tap to change federal state")
                    .accessibilityAddTraits(.isButton)
                    .debugBorder(Color.blue.opacity(0.8), cornerRadius: 20, isVisible: debugBordersEnabled)
                    
                    FederalStateSloganBlock(stateName: selectedState)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .debugBorder(Color.cyan.opacity(0.8), cornerRadius: 16, isVisible: debugBordersEnabled)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .padding(.bottom, MainScreenConstants.adaptiveValue(8))
                }
            }
            
            MainMascotView(
                messageKey: "eagle_desc_chick",
                messageParameters: [String(readinessPercentage)],
                leadingMessage: testDateMessage,
                showDialog: $showDialog,
                autoPlayInterval: 60
            )
            .debugBorder(Color.green.opacity(0.8), cornerRadius: 20, isVisible: debugBordersEnabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, standardPadding + 4)
        .padding(.horizontal, standardPadding)
        .background(
            RoundedRectangle(cornerRadius: containerCornerRadius)
                .fill(Color.accentColor)
        )
        .debugBorder(Color.red.opacity(0.85), cornerRadius: containerCornerRadius, isVisible: debugBordersEnabled)
        .padding(.horizontal)
        .padding(.top, MainScreenConstants.adaptiveValue(8))
        .padding(.bottom, MainScreenConstants.adaptiveValue(8))
    }
    
    private func getLocalizedStateName(_ stateName: String) -> String {
        return stateName.localized
    }

    private var testDateMessage: String? {
        guard let date = savedTestDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let testDay = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: today, to: testDay).day ?? 0
        
        guard days >= 0 else { return nil }
        guard days <= 365 else { return nil }
        
        if days == 0 {
            return "main_header_test_today".localized
        }
        
        let languageCode = LanguageManager.currentAppLanguageCode
        let dayWord = localizedDayWord(for: days, languageCode: languageCode)
        
        return String(
            format: "main_header_test_in_days".localized,
            days,
            dayWord
        )
    }
    
    private var readinessPercentage: Int {
        let storedValue = UserDefaults.standard.integer(forKey: "readinessPercentage")
        if storedValue > 0 {
            return min(storedValue, 100)
        }
        return 65
    }
    
    private func localizedDayWord(for days: Int, languageCode: String) -> String {
        switch languageCode {
        case "de":
            return days == 1 ? "Tag" : "Tage"
        case "ru":
            let lastDigit = days % 10
            let lastTwoDigits = days % 100
            if lastTwoDigits >= 11 && lastTwoDigits <= 14 { return "дней" }
            switch lastDigit {
            case 1: return "день"
            case 2, 3, 4: return "дня"
            default: return "дней"
            }
        case "uk":
            let lastDigit = days % 10
            let lastTwoDigits = days % 100
            if lastTwoDigits >= 11 && lastTwoDigits <= 14 { return "днів" }
            switch lastDigit {
            case 1: return "день"
            case 2, 3, 4: return "дні"
            default: return "днів"
            }
        default:
            return days == 1 ? "day" : "days"
        }
    }
}

// MARK: - Federal State Slogan Block
private struct FederalStateSloganBlock: View {
    @EnvironmentObject private var languageManager: LanguageManager
    
    let stateName: String
    
    var body: some View {
        Text(localizedSlogan(for: stateName))
            .font(.system(.callout, design: .rounded).weight(.medium))
            .foregroundColor(Color(.systemGray6))
            .multilineTextAlignment(.leading)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 2)
            .accessibilityLabel("State Slogan")
            .accessibilityValue(localizedSlogan(for: stateName))
            .id(languageManager.currentAppLanguage)
    }
    
    private func localizedSlogan(for state: String) -> String {
        let normalized = state
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
        let key = "state_\(normalized)_slogan"
        let localizedValue = key.localized
        
        if localizedValue == key {
            let fallbackKey = "state_\(normalized)"
            return fallbackKey.localized
        }
        
        return localizedValue
    }
}

// MARK: - Debug Helpers
private extension View {
    func debugBorder(_ color: Color, cornerRadius: CGFloat = 0, isVisible: Bool) -> some View {
        overlay(
            Group {
                if isVisible {
                    if cornerRadius > 0 {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(color, style: StrokeStyle(lineWidth: 2, dash: [6, 3]))
                    } else {
                        Rectangle()
                            .stroke(color, style: StrokeStyle(lineWidth: 2, dash: [6, 3]))
                    }
                }
            }
        )
    }
}

// MARK: - Preview
#Preview {
    MainHeaderContent(
        showDialog: .constant(true),
        savedTestDate: .constant(nil),
        onStateButtonTapped: {
            print("State button tapped")
        }
    )
    .environmentObject(StateManager())
}
