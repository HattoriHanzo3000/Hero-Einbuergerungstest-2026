import SwiftUI

// MARK: - Onboarding Header Card (Liquid Glass, matches ScreenHeaderCard style)
struct OnboardingHeaderComponent: View {
    let currentStep: Int
    let totalSteps: Int
    let messageKey: String
    let messageParameters: [String]?
    let selectedState: String?
    @Binding var showDialog: Bool
    
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    init(
        currentStep: Int,
        totalSteps: Int,
        messageKey: String,
        messageParameters: [String]? = nil,
        selectedState: String? = nil,
        showDialog: Binding<Bool>
    ) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.messageKey = messageKey
        self.messageParameters = messageParameters
        self.selectedState = selectedState
        self._showDialog = showDialog
    }
    
    private var verticalPadding: CGFloat { layoutMetrics.adaptive(18) }
    private var horizontalPadding: CGFloat { layoutMetrics.adaptive(20) }
    private var mascotToContentSpacing: CGFloat { layoutMetrics.adaptive(16) }
    private var titleToSloganSpacing: CGFloat { layoutMetrics.adaptive(6) }
    private var mascotSize: CGFloat { layoutMetrics.adaptive(104) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Progress bar (matches SpacedRepetitionQuestionCard: horizontal 20, vertical padding)
            ProgressView(value: Double(currentStep), total: Double(totalSteps))
                .progressViewStyle(LinearProgressViewStyle(tint: Color(.systemGray6)))
                .frame(height: layoutMetrics.adaptive(8))
                .clipShape(Capsule())
                .frame(maxWidth: .infinity)
                .padding(.horizontal, layoutMetrics.adaptive(20))
                .padding(.top, layoutMetrics.adaptive(18))
                .padding(.bottom, layoutMetrics.adaptive(12))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Progress")
                .accessibilityValue("\(currentStep) of \(totalSteps)")
            
            // Mascot + content row (same layout as ScreenHeaderCard)
            HStack(alignment: .center, spacing: mascotToContentSpacing) {
                if let selectedState = selectedState {
                    // With title: state name + slogan (ScreenHeaderCard style)
                    VStack(alignment: .leading, spacing: titleToSloganSpacing) {
                        Text(getLocalizedStateName(selectedState))
                            .font(.system(.title, weight: .heavy))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        OnboardingSloganBlock(stateName: selectedState, textColor: .white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    // Without title: message only (matches Categories mascot message)
                    Text(formattedMessage)
                        .font(.system(.body, weight: .semibold))
                        .italic()
                        .lineSpacing(4)
                        .foregroundColor(.white)
                        .id(languageManager.currentAppLanguage)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Image("MascotLiDHeader")
                    .resizable()
                    .scaledToFit()
                .frame(width: mascotSize, height: mascotSize)
                .scaleEffect(x: -1, y: 1, anchor: .center)
            }
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LiquidGlassBackground(gradient: .blue))
        .clipShape(RoundedRectangle(cornerRadius: layoutMetrics.adaptive(32), style: .continuous))
        .overlay(HeaderBorderOverlay())
        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
        .padding(.horizontal)
        .padding(.top, layoutMetrics.adaptive(8))
    }
    
    private var formattedMessage: String {
        // Onboarding copy follows the current app language (updates when user picks a language on step 1).
        let languageCode = languageManager.currentAppLanguage
        let localizedString = messageKey.localized(for: languageCode)
        guard let parameters = messageParameters, !parameters.isEmpty else { return localizedString }
        let locale = Locale(identifier: languageManager.currentAppLanguage)
        let formatArguments: [CVarArg] = parameters.map { parameter in
            if let intValue = Int(parameter) { return intValue }
            if let doubleValue = Double(parameter) { return Int(doubleValue.rounded()) }
            return parameter as NSString
        }
        return String(format: localizedString, locale: locale, arguments: formatArguments)
    }
    
    private func getLocalizedStateName(_ stateName: String) -> String {
        stateName.localized
    }
    
}

// MARK: - Onboarding Slogan Block (matches FederalStateSloganBlock, Categories mascot message)
private struct OnboardingSloganBlock: View {
    @EnvironmentObject private var languageManager: LanguageManager
    let stateName: String
    var textColor: Color = .white
    
    var body: some View {
        Text(localizedSlogan(for: stateName))
            .font(.system(.body, weight: .semibold))
            .italic()
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
            return "state_\(normalized)".localized
        }
        return localizedValue
    }
}
