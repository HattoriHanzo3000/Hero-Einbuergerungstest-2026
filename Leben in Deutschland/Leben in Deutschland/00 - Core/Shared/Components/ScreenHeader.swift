//
//  ScreenHeader.swift
//  Leben in Deutschland
//
//  Shared header for mascot + message screens (Home, Test, Progress).
//  Uses HeaderContainer with MainMascotView and optional trailing content.
//

import SwiftUI

// MARK: - Screen Header Content
/// Defines the trailing content type beside the mascot.
enum ScreenHeaderContent: Equatable {
    /// State title + slogan (Home).
    case state(stateName: String)
    /// Single message text (Test date, etc.).
    case message(String)
    /// Mascot + progress text in separate containers (Progress).
    case readiness
}

// MARK: - Screen Header
struct ScreenHeader: View {
    let readinessPercentage: Int
    @Binding var showDialog: Bool
    var leadingMessage: String?
    var onPremiumTap: (() -> Void)?
    var autoPlayInterval: TimeInterval? = 60
    var content: ScreenHeaderContent

    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var stateManager: StateManager
    @Environment(\.layoutMetrics) private var layoutMetrics

    private var mascotToContentSpacing: CGFloat { layoutMetrics.adaptive(16) }
    private var titleToSloganSpacing: CGFloat { layoutMetrics.adaptive(6) }
    private var mascotSize: CGFloat { layoutMetrics.adaptive(120) }

    var body: some View {
        HeaderContainer(showPremiumButton: onPremiumTap != nil, onPremiumTap: onPremiumTap) {
            Group {
                switch content {
                case .readiness, .state, .message:
                    mascotWithContentLayout
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityAddTraits(.isHeader)
        .id(languageManager.currentAppLanguage)
    }

    private var mascotWithContentLayout: some View {
        HStack(alignment: .center, spacing: mascotToContentSpacing) {
            MainMascotView(
                messageKey: "eagle_desc_chick",
                messageParameters: content == .readiness ? [String(readinessPercentage)] : nil,
                leadingMessage: content == .readiness ? nil : leadingMessage,
                showDialog: $showDialog,
                autoPlayInterval: content == .readiness ? nil : autoPlayInterval,
                hideBubble: true,
                showMessageWhenBubbleHidden: false
            )
            .frame(width: mascotSize, height: mascotSize)

            trailingContentView
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var trailingContentView: some View {
        switch content {
        case .readiness:
            messageContent(text: formattedReadinessMessage)
        case .state(let stateName):
            stateContent(stateName: stateName)
        case .message(let text):
            messageContent(text: text)
        }
    }

    private var formattedReadinessMessage: String {
        let key = "eagle_desc_chick"
        let localized = key.localized
        let locale = Locale(identifier: languageManager.currentAppLanguage)
        return String(format: localized, locale: locale, readinessPercentage)
    }

    @ViewBuilder
    private func stateContent(stateName: String) -> some View {
        VStack(alignment: .leading, spacing: titleToSloganSpacing) {
            Text(getLocalizedStateName(stateName))
                .font(.system(.title, design: .rounded).bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .id("state_title_\(stateName)")
                .accessibilityLabel("main_header_state_accessibility_label".localized)
                .accessibilityValue(getLocalizedStateName(stateName))
                .accessibilityHint("main_header_state_accessibility_hint".localized)
                .accessibilityAddTraits(.isStaticText)

            FederalStateSloganBlock(stateName: stateName, textColor: .white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func messageContent(text: String) -> some View {
        Text(text)
            .font(.system(.body, design: .rounded).weight(.medium))
            .lineSpacing(4)
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel("main_header_test_date_accessibility_label".localized)
            .accessibilityValue(text)
    }

    private func getLocalizedStateName(_ stateName: String) -> String {
        stateName.localized
    }
}

// MARK: - Federal State Slogan Block
/// Styled to match header text: .body, .rounded, .medium, lineSpacing(4).
struct FederalStateSloganBlock: View {
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

// MARK: - Preview
#Preview("State") {
    ScreenHeader(
        readinessPercentage: 72,
        showDialog: .constant(true),
        leadingMessage: nil,
        onPremiumTap: {},
        content: .state(stateName: "Bavaria")
    )
    .environmentObject(LanguageManager())
    .environmentObject(StateManager.shared)
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

#Preview("Message") {
    ScreenHeader(
        readinessPercentage: 72,
        showDialog: .constant(true),
        leadingMessage: "14 days left",
        onPremiumTap: {},
        content: .message("14 days left")
    )
    .environmentObject(LanguageManager())
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

#Preview("Readiness") {
    ScreenHeader(
        readinessPercentage: 72,
        showDialog: .constant(true),
        onPremiumTap: {},
        content: .readiness
    )
    .environmentObject(LanguageManager())
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
