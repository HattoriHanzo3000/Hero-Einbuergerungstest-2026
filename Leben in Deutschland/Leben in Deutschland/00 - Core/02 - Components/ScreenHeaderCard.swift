//
//  ScreenHeaderCard.swift
//  Leben in Deutschland
//
//  Header card for mascot + message screens (Home, Test, Progress).
//  Uses HeaderCard with MascotView and optional trailing content.
//

import SwiftUI
import Combine

@MainActor
final class SharedHeaderRotationState: ObservableObject {
    static let shared = SharedHeaderRotationState()
    @Published var messageIndex: Int = 0

    private init() {}
}

// MARK: - Screen Header Card Content
/// Defines the trailing content type beside the mascot.
enum ScreenHeaderCardContent: Equatable {
    /// State title + slogan (Home). No alternating when mascot animates.
    case state(stateName: String)
    /// State title + slogan alternating with test date and optional readiness when mascot animates.
    case stateWithTestDate(stateName: String, testDateMessage: String, readinessMessage: String? = nil)
    /// Alternating readiness + test date only (Progress). No state title or slogan.
    case readinessWithTestDate(readinessMessage: String, testDateMessage: String)
    /// Single message text (Test date, etc.).
    case message(String)
    /// Mascot + progress text in separate containers (Progress).
    case readiness
}

private extension ScreenHeaderCardContent {
    var isAlternatingOnMascotAnimation: Bool {
        if case .stateWithTestDate = self { return true }
        if case .readinessWithTestDate = self { return true }
        return false
    }

    /// Number of messages to cycle through (slogan + test date + optional readiness, or readiness + test date).
    var messageCountForAlternating: Int {
        switch self {
        case .stateWithTestDate(_, _, let readiness): return readiness != nil ? 3 : 2
        case .readinessWithTestDate: return 2
        default: return 2
        }
    }
}

// MARK: - Screen Header Card
/// Header for mascot + message screens (Home, Progress). When useCard is false, renders content only for flat gradient headers.
struct ScreenHeaderCard: View {
    let readinessPercentage: Int
    /// Subscription state used for free/pro header variants.
    var isProUser: Bool = false
    var autoPlayInterval: TimeInterval? = 60
    var content: ScreenHeaderCardContent
    /// When false, renders content only (no rounded card). Use with gradient background for flat header (Home, Progress).
    var useCard: Bool = true
    /// When `true`, mirrors the mascot horizontally (Home + Progress headers). Other headers use `false`.
    var mascotHorizontallyFlipped: Bool = false

    /// Shared across Home + Progress so tab switching keeps the same header rotation state.
    @ObservedObject private var rotationState = SharedHeaderRotationState.shared
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var stateManager: StateManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.layoutMetrics) private var layoutMetrics

    private var mascotToContentSpacing: CGFloat { layoutMetrics.adaptive(16) }
    private var titleToSloganSpacing: CGFloat { layoutMetrics.adaptive(6) }
    private var mascotSize: CGFloat { layoutMetrics.adaptive(120) }

    private var proRowSpacing: CGFloat { layoutMetrics.adaptive(12) }

    private var useHomeHeaderLayout: Bool {
        switch content {
        case .state, .stateWithTestDate, .readinessWithTestDate, .readiness: return true
        case .message: return false
        }
    }

    var body: some View {
        Group {
            if useCard {
                HeaderCard(showProButton: false) {
                    headerContent
                }
            } else {
                headerContent
            }
        }
        .accessibilityAddTraits(.isHeader)
        .id(languageManager.currentAppLanguage)
    }

    /// Reusable content (state, slogan, mascot, pro). No card wrapper.
    private var headerContent: some View {
        Group {
            if useHomeHeaderLayout {
                homeHeaderLayout
            } else {
                VStack(alignment: .leading, spacing: proRowSpacing) {
                    headerProRow
                    mascotWithContentLayout
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }

    /// Home layout: left = state + message (flexible); right = pro (row 1) + mascot (row 2), fixed positions.
    @ViewBuilder
    private var homeHeaderLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerProRow
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .top, spacing: mascotToContentSpacing) {
                // Left: state + mascot message (wraps as needed)
                VStack(alignment: .leading, spacing: proRowSpacing) {
                    stateTitleRow
                        .frame(maxWidth: .infinity, alignment: .leading)

                    mascotMessageRow
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(.easeInOut(duration: 0.35), value: rotationState.messageIndex)

                // Right: mascot (fixed position)
                VStack(alignment: .trailing, spacing: proRowSpacing) {
                    MascotView(
                        horizontalMirror: mascotHorizontallyFlipped,
                        autoPlayInterval: autoPlayInterval,
                        onAnimationStart: content.isAlternatingOnMascotAnimation ? {
                            withAnimation(.easeInOut(duration: 0.35)) { advanceMessageIndex() }
                        } : nil
                    )
                    .frame(width: mascotSize, height: mascotSize)
                }
                .fixedSize(horizontal: true, vertical: false)
            }
            .padding(.top, layoutMetrics.adaptive(8))
            .padding(.bottom, layoutMetrics.adaptive(12))
        }
    }

    @ViewBuilder
    private var headerProRow: some View {
        HStack(spacing: layoutMetrics.adaptive(8)) {
            ProBadge(color: .white, showShimmer: true)
                .fixedSize(horizontal: true, vertical: false)

            if !isProUser {
                TestNowForFreeChip(color: .white) {
                    subscriptionManager.presentPaywall(placement: "home_header_free_chip")
                }
                .fixedSize(horizontal: true, vertical: false)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isProUser)
    }

    @ViewBuilder
    private var stateTitleRow: some View {
        switch content {
        case .state(let stateName):
            stateTitleText(stateName: stateName)
        case .stateWithTestDate(let stateName, _, _):
            stateTitleText(stateName: stateName)
        case .readinessWithTestDate, .readiness:
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
        case .readinessWithTestDate(let readinessMessage, let testDateMessage):
            readinessWithTestDateAlternatingMessage(readinessMessage: readinessMessage, testDateMessage: testDateMessage)
        case .readiness:
            messageContent(text: formattedReadinessMessage)
        case .message(let text):
            messageContent(text: text)
        }
    }

    private var mascotWithContentLayout: some View {
        HStack(alignment: .center, spacing: mascotToContentSpacing) {
            MascotView(
                horizontalMirror: mascotHorizontallyFlipped,
                autoPlayInterval: content == .readiness ? nil : autoPlayInterval,
                onAnimationStart: content.isAlternatingOnMascotAnimation ? {
                    withAnimation(.easeInOut(duration: 0.35)) { advanceMessageIndex() }
                } : nil
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
        case .readinessWithTestDate(let readinessMessage, let testDateMessage):
            readinessWithTestDateAlternatingMessage(readinessMessage: readinessMessage, testDateMessage: testDateMessage)
        case .message(let text):
            messageContent(text: text)
        }
    }

    private var formattedReadinessMessage: String {
        ReadinessMessageHelper.message(readinessPercentage: readinessPercentage, languageCode: languageManager.currentAppLanguage)
    }

    private func advanceMessageIndex() {
        let count = content.messageCountForAlternating
        rotationState.messageIndex = (rotationState.messageIndex + 1) % count
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
        let idx = rotationState.messageIndex % count
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
        .animation(.easeInOut(duration: 0.25), value: rotationState.messageIndex)
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

    @ViewBuilder
    private func readinessWithTestDateAlternatingMessage(readinessMessage: String, testDateMessage: String) -> some View {
        let idx = rotationState.messageIndex % 2

        ZStack(alignment: .leading) {
            if idx == 0 {
                Text(readinessMessage)
                    .font(.system(.body, weight: .semibold))
                    .italic()
                    .lineSpacing(4)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
            } else {
                Text(testDateMessage)
                    .font(.system(.body, weight: .semibold))
                    .italic()
                    .lineSpacing(4)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: rotationState.messageIndex)
        .frame(maxWidth: .infinity, alignment: .leading)
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
