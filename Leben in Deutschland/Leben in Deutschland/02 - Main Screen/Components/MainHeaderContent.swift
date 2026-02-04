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
    
    // Adaptive layout metrics — match Progress tab header (liquid glass, rounded)
    private var verticalPadding: CGFloat { layoutMetrics.adaptive(18) }
    private var horizontalPadding: CGFloat { layoutMetrics.adaptive(20) }
    /// Space between mascot and right column (title + slogan) — same as mascot-to-text in Progress (16).
    private var mascotToContentSpacing: CGFloat { layoutMetrics.adaptive(16) }
    /// Space between land title and slogan in the right column.
    private var titleToSloganSpacing: CGFloat { layoutMetrics.adaptive(6) }
    
    var body: some View {
        HStack(alignment: .center, spacing: mascotToContentSpacing) {
            MainMascotView(
                messageKey: "eagle_desc_chick",
                messageParameters: [String(readinessPercentage)],
                leadingMessage: testDateMessage,
                showDialog: $showDialog,
                autoPlayInterval: 60,
                hideBubble: true,
                showMessageWhenBubbleHidden: false
            )
            .fixedSize(horizontal: true, vertical: false)
            .debugBorder(Color.green.opacity(0.8), cornerRadius: 20, isVisible: debugBordersEnabled)
            
            VStack(alignment: .leading, spacing: titleToSloganSpacing) {
                stateTitleSection
                sloganSection
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .background(learnHeaderLiquidGlassBackground)
        .clipShape(RoundedRectangle(cornerRadius: layoutMetrics.adaptive(32), style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: layoutMetrics.adaptive(32), style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.4), .white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
        )
        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
        .debugBorder(Color.red.opacity(0.85), cornerRadius: 0, isVisible: debugBordersEnabled)
        .accessibilityAddTraits(.isHeader)
    }
    
    private var learnHeaderLiquidGlassBackground: some View {
        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(32), style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color("AppBlueLagoon").opacity(0.9),
                        Color("AppBlueLagoon").opacity(0.65),
                        Color("AppCaribean").opacity(0.45)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.20),
                        Color.white.opacity(0.05),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(38), style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.45), Color.white.opacity(0.12)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.6
                    )
            )
            .background(
                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(38), style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )
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
    var stateTitleSection: some View {
        if let selectedState = selectedState {
            Text(getLocalizedStateName(selectedState))
                .font(.system(.title, design: .rounded).bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .id("state_title_\(selectedState)")
                .accessibilityLabel("main_header_state_accessibility_label".localized)
                .accessibilityValue(getLocalizedStateName(selectedState))
                .accessibilityHint("main_header_state_accessibility_hint".localized)
                .accessibilityAddTraits(.isStaticText)
                .debugBorder(Color.blue.opacity(0.8), cornerRadius: 20, isVisible: debugBordersEnabled)
        }
    }
    
    @ViewBuilder
    var sloganSection: some View {
        if let selectedState = selectedState {
            FederalStateSloganBlock(stateName: selectedState, textColor: .white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Federal State Slogan Block
/// Styled to match the Progress header text (mascot message): .body, .rounded, .medium, lineSpacing(4).
private struct FederalStateSloganBlock: View {
    @EnvironmentObject private var languageManager: LanguageManager

    let stateName: String
    var textColor: Color = Color(.label)

    var body: some View {
        Text(localizedSlogan(for: stateName))
            .font(.system(.body, design: .rounded).weight(.medium))
            .lineSpacing(4)
            .foregroundColor(textColor)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
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
