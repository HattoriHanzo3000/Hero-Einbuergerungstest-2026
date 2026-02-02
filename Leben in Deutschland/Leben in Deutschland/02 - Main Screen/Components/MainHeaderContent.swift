import SwiftUI

// MARK: - Main Header Content
struct MainHeaderContent: View {
    let readinessPercentage: Int
    @Binding var showDialog: Bool
    @Binding var savedTestDate: Date?
    private let debugBordersEnabled = false
    
    @EnvironmentObject private var stateManager: StateManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    private var selectedState: String? {
        stateManager.selectedState
    }
    
    // Adaptive layout metrics
    private var topPadding: CGFloat { layoutMetrics.adaptive(56) }
    private var bottomPadding: CGFloat { layoutMetrics.adaptive(18) }
    private var horizontalPadding: CGFloat { layoutMetrics.adaptive(24) }
    private var headerSpacing: CGFloat { layoutMetrics.adaptive(12) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: headerSpacing) {
            stateInformationSection
            
            MainMascotView(
                messageKey: "eagle_desc_chick",
                messageParameters: [String(readinessPercentage)],
                leadingMessage: testDateMessage,
                showDialog: $showDialog,
                autoPlayInterval: 60
            )
            .debugBorder(Color.green.opacity(0.8), cornerRadius: 20, isVisible: debugBordersEnabled)
        }
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
        .padding(.horizontal, horizontalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            HeroHeaderBackground()
                .ignoresSafeArea(edges: .top)
        }
        .shadow(color: Color.black.opacity(0.08), radius: 12, y: 10)
        .debugBorder(Color.red.opacity(0.85), cornerRadius: 0, isVisible: debugBordersEnabled)
        .accessibilityAddTraits(.isHeader)
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

private extension MainHeaderContent {
    @ViewBuilder
    var stateInformationSection: some View {
        Group {
            if let selectedState = selectedState {
                VStack(alignment: .leading, spacing: layoutMetrics.adaptive(8)) {
                    Text(getLocalizedStateName(selectedState))
                        .font(.system(.largeTitle, design: .rounded).bold())
                        .foregroundColor(Color(.label))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .id("state_title_\(selectedState)")
                        .accessibilityLabel("main_header_state_accessibility_label".localized)
                        .accessibilityValue(getLocalizedStateName(selectedState))
                        .accessibilityHint("main_header_state_accessibility_hint".localized)
                        .accessibilityAddTraits(.isStaticText)
                        .debugBorder(Color.blue.opacity(0.8), cornerRadius: 20, isVisible: debugBordersEnabled)
                    
                    FederalStateSloganBlock(stateName: selectedState)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .debugBorder(Color.cyan.opacity(0.8), cornerRadius: 16, isVisible: debugBordersEnabled)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .padding(.bottom, layoutMetrics.adaptive(8))
                        .id(selectedState)
                }
            }
        }
        .id(selectedState ?? "no_state")
    }
}

// MARK: - Federal State Slogan Block
private struct FederalStateSloganBlock: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    let stateName: String
    
    var body: some View {
        Text(localizedSlogan(for: stateName))
            .font(.system(.body, design: .rounded).weight(.semibold))
            .foregroundColor(Color(.label))
            .multilineTextAlignment(.leading)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, layoutMetrics.adaptive(2))
            .accessibilityLabel("main_header_state_slogan_accessibility_label".localized)
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
        readinessPercentage: 72,
        showDialog: .constant(true),
        savedTestDate: .constant(nil)
    )
    .environmentObject(LanguageManager())
    .environmentObject(StateManager.shared)
}
