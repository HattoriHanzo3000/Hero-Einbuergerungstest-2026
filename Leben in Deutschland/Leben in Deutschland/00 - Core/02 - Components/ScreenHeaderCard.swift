//
//  ScreenHeaderCard.swift
//  Leben in Deutschland
//
//  Header card for mascot + message screens (Home, Test, Progress).
//  Uses HeaderCard with MascotView and optional trailing content.
//

import SwiftUI

// MARK: - Screen Header Card Content
/// Defines the trailing content type beside the mascot.
enum ScreenHeaderCardContent: Equatable {
    /// State title + slogan (Home).
    case state(stateName: String)
    /// State title + slogan alternating with test date and optional readiness when mascot animates.
    case stateWithTestDate(stateName: String, testDateMessage: String, readinessMessage: String? = nil)
    /// Single message text (Test date, etc.).
    case message(String)
    /// Mascot + progress text in separate containers (Progress).
    case readiness
}

private extension ScreenHeaderCardContent {
    var isStateWithTestDate: Bool {
        if case .stateWithTestDate = self { return true }
        return false
    }

    /// Number of messages to cycle through (slogan + test date + optional readiness).
    var messageCountForAlternating: Int {
        guard case .stateWithTestDate(_, _, let readiness) = self else { return 2 }
        return readiness != nil ? 3 : 2
    }
}

// MARK: - Screen Header Card
/// Header for mascot + message screens (Home, Progress). When useCard is false, renders content only for flat gradient headers.
struct ScreenHeaderCard: View {
    let readinessPercentage: Int
    var onPremiumTap: (() -> Void)?
    var autoPlayInterval: TimeInterval? = 60
    var content: ScreenHeaderCardContent
    /// When false, renders content only (no rounded card). Use with gradient background for flat header (Home, Progress).
    var useCard: Bool = true
    /// Base name for the mascot asset used in this header (e.g. "MainChick" or "MainChickFlipped").
    var mascotAssetBaseName: String = "MainChick"

    /// 0 = slogan, 1 = test date, 2 = readiness (when provided). Cycles on mascot animation.
    @State private var messageIndex = 0
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var stateManager: StateManager
    @Environment(\.layoutMetrics) private var layoutMetrics

    private var mascotToContentSpacing: CGFloat { layoutMetrics.adaptive(16) }
    private var titleToSloganSpacing: CGFloat { layoutMetrics.adaptive(6) }
    private var mascotSize: CGFloat { layoutMetrics.adaptive(120) }

    private var premiumRowSpacing: CGFloat { layoutMetrics.adaptive(12) }

    private var useHomeHeaderLayout: Bool {
        switch content {
        case .state, .stateWithTestDate, .readiness: return true
        case .message: return false
        }
    }

    var body: some View {
        Group {
            if useCard {
                HeaderCard(showPremiumButton: false) {
                    headerContent
                }
            } else {
                headerContent
            }
        }
        .accessibilityAddTraits(.isHeader)
        .id(languageManager.currentAppLanguage)
    }

    /// Reusable content (state, slogan, mascot, premium). No card wrapper.
    private var headerContent: some View {
        Group {
            if useHomeHeaderLayout {
                homeHeaderLayout
            } else {
                VStack(alignment: .leading, spacing: premiumRowSpacing) {
                    if onPremiumTap != nil {
                        PremiumButton(action: { onPremiumTap?() }, color: .white)
                            .scaleEffect(0.8)
                            .frame(maxWidth: .infinity)
                    }
                    mascotWithContentLayout
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }

    /// Home layout: left = state + message (flexible); right = premium (row 1) + mascot (row 2), fixed positions.
    @ViewBuilder
    private var homeHeaderLayout: some View {
        HStack(alignment: .top, spacing: mascotToContentSpacing) {
            // Left: state + mascot message (wraps as needed)
            VStack(alignment: .leading, spacing: premiumRowSpacing) {
                stateTitleRow
                    .frame(maxWidth: .infinity, alignment: .leading)

                mascotMessageRow
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right: premium always row 1, mascot always row 2 — fixed positions
            VStack(alignment: .trailing, spacing: premiumRowSpacing) {
                if onPremiumTap != nil {
                    PremiumButton(action: { onPremiumTap?() }, color: .white)
                        .fixedSize(horizontal: true, vertical: false)
                }

                MascotView(
                    assetBaseName: mascotAssetBaseName,
                    autoPlayInterval: autoPlayInterval,
                    onAnimationStart: content.isStateWithTestDate ? { advanceMessageIndex() } : nil
                )
                .frame(width: mascotSize, height: mascotSize)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
    }

    @ViewBuilder
    private var stateTitleRow: some View {
        switch content {
        case .state(let stateName):
            stateTitleText(stateName: stateName)
        case .stateWithTestDate(let stateName, _, _):
            stateTitleText(stateName: stateName)
        case .readiness:
            EmptyView()
        default:
            EmptyView()
        }
    }

    private func stateTitleText(stateName: String) -> some View {
        Text(getLocalizedStateName(stateName))
            .font(.system(.title, weight: .heavy))
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
    }

    @ViewBuilder
    private var mascotMessageRow: some View {
        switch content {
        case .state(let stateName):
            FederalStateSloganBlock(stateName: stateName, textColor: .white)
                .frame(maxWidth: .infinity, alignment: .leading)
        case .stateWithTestDate(let stateName, let testDateMessage, let readinessMessage):
            stateContentWithAlternatingMessage(stateName: stateName, testDateMessage: testDateMessage, readinessMessage: readinessMessage)
        case .readiness:
            messageContent(text: formattedReadinessMessage)
        default:
            EmptyView()
        }
    }

    private var mascotWithContentLayout: some View {
        HStack(alignment: .center, spacing: mascotToContentSpacing) {
            MascotView(
                assetBaseName: mascotAssetBaseName,
                autoPlayInterval: content == .readiness ? nil : autoPlayInterval,
                onAnimationStart: content.isStateWithTestDate ? { advanceMessageIndex() } : nil
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
        case .stateWithTestDate(let stateName, let testDateMessage, let readinessMessage):
            stateContentWithAlternating(stateName: stateName, testDateMessage: testDateMessage, readinessMessage: readinessMessage)
        case .message(let text):
            messageContent(text: text)
        }
    }

    private var formattedReadinessMessage: String {
        ReadinessMessageHelper.message(readinessPercentage: readinessPercentage, languageCode: languageManager.currentAppLanguage)
    }

    private func advanceMessageIndex() {
        let count = content.messageCountForAlternating
        messageIndex = (messageIndex + 1) % count
    }

    @ViewBuilder
    private func stateContent(stateName: String) -> some View {
        VStack(alignment: .leading, spacing: titleToSloganSpacing) {
            Text(getLocalizedStateName(stateName))
                .font(.system(.title, weight: .heavy))
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

    @ViewBuilder
    private func stateContentWithAlternatingMessage(stateName: String, testDateMessage: String, readinessMessage: String?) -> some View {
        let count = readinessMessage != nil ? 3 : 2
        let idx = messageIndex % count
        let textMessage = idx == 1 ? testDateMessage : (readinessMessage ?? testDateMessage)

        ZStack(alignment: .leading) {
            if idx == 0 {
                FederalStateSloganBlock(stateName: stateName, textColor: .white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
            } else {
                Text(textMessage)
                    .font(.system(.body, weight: .semibold))
                    .italic()
                    .lineSpacing(4)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: messageIndex)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func stateContentWithAlternating(stateName: String, testDateMessage: String, readinessMessage: String?) -> some View {
        VStack(alignment: .leading, spacing: titleToSloganSpacing) {
            Text(getLocalizedStateName(stateName))
                .font(.system(.title, weight: .heavy))
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

            stateContentWithAlternatingMessage(stateName: stateName, testDateMessage: testDateMessage, readinessMessage: readinessMessage)
        }
    }

    private func messageContent(text: String) -> some View {
        Text(text)
            .font(.system(.body, weight: .semibold))
            .italic()
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
/// SF Pro Semibold Italic, lineSpacing(4). Matches Categories mascot message.
struct FederalStateSloganBlock: View {
    @EnvironmentObject private var languageManager: LanguageManager

    let stateName: String
    var textColor: Color = Color(.label)

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
            let fallbackKey = "state_\(normalized)"
            return fallbackKey.localized
        }

        return localizedValue
    }
}
