//
//  TestHeaderContent.swift
//  Leben in Deutschland
//
//  Header for the Test tab: same liquid glass style as main header, with mascot and test date message only.
//

import SwiftUI

// MARK: - Test Header Content
/// Test tab header: mascot on the left, days-until-test message on the right. Same visual style as MainHeaderContent.
struct TestHeaderContent: View {
    let readinessPercentage: Int
    @Binding var showDialog: Bool
    @Binding var savedTestDate: Date?

    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var premiumManager: PremiumManager

    private var verticalPadding: CGFloat { layoutMetrics.adaptive(18) }
    private var horizontalPadding: CGFloat { layoutMetrics.adaptive(20) }
    private var mascotToContentSpacing: CGFloat { layoutMetrics.adaptive(16) }

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

            testDateSection
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, verticalPadding)
        .padding(.horizontal, horizontalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .background(liquidGlassBackground)
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
        .accessibilityAddTraits(.isHeader)
        .overlay(alignment: .topTrailing) {
            PremiumCrownButton(action: { premiumManager.presentPaywall() }, color: .white)
                .padding(.top, layoutMetrics.adaptive(12))
                .padding(.trailing, layoutMetrics.adaptive(12))
        }
    }

    private var liquidGlassBackground: some View {
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

    private var testDateMessage: String? {
        guard let date = savedTestDate else { return nil }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let testDay = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: today, to: testDay).day ?? 0

        guard days >= 0 else { return nil }
        guard days <= 365 else { return nil }

        if days == 0 {
            return "perfect_test_today".localized
        }
        let key: String
        if days == 1 {
            key = "perfect_day_left"
        } else if days >= 2 && days <= 4 {
            key = "perfect_days_left_2_4"
        } else {
            key = "perfect_days_left"
        }
        return String(format: key.localized, days)
    }
}

// MARK: - Test Date Section
private extension TestHeaderContent {
    @ViewBuilder
    var testDateSection: some View {
        let message = testDateMessage ?? "test_header_set_date_prompt".localized
        Text(message)
            .font(.system(.body, design: .rounded).weight(.medium))
            .lineSpacing(4)
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel("main_header_test_date_accessibility_label".localized)
            .accessibilityValue(message)
    }
}

// MARK: - Preview
#Preview {
    TestHeaderContent(
        readinessPercentage: 72,
        showDialog: .constant(true),
        savedTestDate: .constant(Date().addingTimeInterval(14 * 86400))
    )
    .environmentObject(LanguageManager())
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
