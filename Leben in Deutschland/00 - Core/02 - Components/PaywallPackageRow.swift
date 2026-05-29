//
//  PaywallPackageRow.swift
//  Leben in Deutschland
//
//  Package row UI for paywall: plan selection, trial badge, price formatting.
//

import SwiftUI
import RevenueCat
import UIKit

// MARK: - SF Pro width variants for paywall subtitles
private extension Font {
    /// SF Pro Condensed Regular at caption size (respects Dynamic Type).
    static var paywallSubtitleCondensed: Font {
        Font(UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .regular, width: .condensed))
    }
    /// SF Pro Expanded Regular at caption size (for "Ends in" + countdown).
    static var paywallSubtitleExpanded: Font {
        Font(UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize, weight: .regular, width: .expanded))
    }
}

// MARK: - Launch Offer Row Badge (rounded rect on top edge of Lifetime button; one string)
private struct LaunchOfferRowBadgeView: View {
    let layoutMetrics: LayoutMetrics

    private let cornerRadius: CGFloat = 12

    var body: some View {
        Text("launch_offer_badge".localized)
            .font(.system(.caption2, weight: .semibold).italic())
            .foregroundStyle(.white)
            .padding(.horizontal, layoutMetrics.adaptive(10))
            .padding(.vertical, layoutMetrics.adaptive(6))
            .background(Color.red)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
    }
}

// MARK: - Trial Shield Badge
/// Orange "3 days free trial" badge with rounded corners.
private struct TrialShieldBadgeView: View {
    let layoutMetrics: LayoutMetrics

    private let cornerRadius: CGFloat = 12

    var body: some View {
        Text("paywall_trial_shield".localized)
            .font(.system(.caption2, weight: .semibold).italic())
            .foregroundStyle(.white)
            .padding(.horizontal, layoutMetrics.adaptive(8))
            .padding(.vertical, layoutMetrics.adaptive(5))
            .background(Color("AppOrange").opacity(1))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
    }
}

// MARK: - Paywall Package Row
struct PaywallPackageRow: View {
    let package: Package
    let isSelected: Bool
    let onSelect: () -> Void
    /// Countdown text for Launch Offer (e.g. "2d 04h 15m 10s"). Nil hides countdown.
    var countdownText: String? = nil
    /// When true, shows "LAUNCH OFFER -50%" badge.
    var showLaunchOfferBadge: Bool = false
    /// Original price shown crossed out when promo is active (e.g. "€19.99").
    var strikethroughPrice: String? = nil

    @Environment(\.layoutMetrics) private var layoutMetrics

    private var planTitle: String {
        if package.identifier == LaunchOfferService.promoPackageIdentifier {
            return "pro_plan_lifetime".localized
        }
        switch package.packageType {
        case .monthly: return "pro_plan_monthly".localized
        case .annual: return "pro_plan_yearly".localized
        case .lifetime: return "pro_plan_lifetime".localized
        case .sixMonth: return "pro_plan_six_month".localized
        case .threeMonth: return "pro_plan_three_month".localized
        case .twoMonth: return "pro_plan_two_month".localized
        case .weekly: return "pro_plan_weekly".localized
        case .custom, .unknown:
            return package.storeProduct.localizedTitle
        }
    }

    /// Slash-format period right after the price: "/mo", "/3mo", etc. No /total for lifetime.
    private var slashPeriodText: String? {
        switch package.packageType {
        case .monthly: return "paywall_slash_month".localized
        case .annual: return "paywall_slash_year".localized
        case .sixMonth: return "paywall_slash_6_months".localized
        case .threeMonth: return "paywall_slash_3_months".localized
        case .twoMonth: return "paywall_slash_2_months".localized
        case .weekly: return "paywall_slash_week".localized
        case .lifetime, .custom, .unknown: return nil
        }
    }

    /// True for Lifetime or promo package — use orange gradient/tint instead of blue.
    private var isLifetimeRow: Bool {
        package.identifier == LaunchOfferService.promoPackageIdentifier || package.packageType == .lifetime
    }

    /// Card background: orange only during launch offer (promo row); after expiry or other plans = blue.
    private var cardBackground: some ShapeStyle {
        if showLaunchOfferBadge {
            return AnyShapeStyle(LiquidGlassGradient.orangePromo.screenBackground)
        } else {
            return AnyShapeStyle(LiquidGlassGradient.blue.screenBackground)
        }
    }

    private var rowOpacity: Double { isSelected ? 1.0 : 0.72 }
    private var rowSaturation: Double { isSelected ? 1.0 : 0.45 }

    /// Plan subtitle: Monthly, 3 Months, Lifetime. When promo active, shows "Pay once, own forever" like regular lifetime.
    private var planSubtitle: String? {
        if showLaunchOfferBadge || package.identifier == LaunchOfferService.promoPackageIdentifier {
            return "paywall_subtitle_lifetime".localized
        }
        switch package.packageType {
        case .monthly: return "paywall_subtitle_monthly".localized
        case .threeMonth: return "paywall_trial_shield".localized
        case .lifetime: return "paywall_subtitle_lifetime".localized
        default: return nil
        }
    }

    /// Second line for Lifetime/promo only: "No hidden fees. No recurring charges."
    private var planSubtitleLine2: String? {
        if isLifetimeRow {
            return "paywall_subtitle_lifetime_no_fees".localized
        }
        return nil
    }

    /// Text and icons white on gradient; when unselected, slightly lower opacity for less contrast.
    private var contentForeground: Color { isSelected ? .white : .white.opacity(0.7) }
    private var secondaryForeground: Color { isSelected ? .white.opacity(0.9) : .white.opacity(0.6) }

    var body: some View {
        ZStack(alignment: .top) {
            Button(action: onSelect) {
                HStack(spacing: layoutMetrics.adaptive(12)) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: layoutMetrics.adaptive(24), weight: .semibold))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.7))

                VStack(alignment: .leading, spacing: layoutMetrics.adaptive(2)) {
                    HStack(spacing: layoutMetrics.adaptive(8)) {
                        Text(planTitle)
                            .font(.system(.headline, weight: .bold))
                            .foregroundStyle(contentForeground)
                    }
                    if let text = planSubtitle {
                        Text(text)
                            .font(.paywallSubtitleCondensed)
                            .foregroundStyle(secondaryForeground)
                    }
                    if let text2 = planSubtitleLine2 {
                        Text(text2)
                            .font(.paywallSubtitleCondensed)
                            .foregroundStyle(secondaryForeground)
                    }
                    if showLaunchOfferBadge, let countdown = countdownText, !countdown.isEmpty {
                        HStack(spacing: layoutMetrics.adaptive(4)) {
                            Text("launch_offer_expires_in".localized)
                                .font(.paywallSubtitleExpanded)
                            Text(countdown)
                                .font(.paywallSubtitleExpanded)
                                .monospacedDigit()
                        }
                        .foregroundStyle(secondaryForeground)
                    }
                }

                Spacer(minLength: 8)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    if let original = strikethroughPrice {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(package.formattedPriceString)
                                .font(.system(.title3, weight: .bold))
                                .foregroundStyle(contentForeground)
                            Text(original)
                                .font(.system(.caption2, weight: .medium))
                                .strikethrough(color: secondaryForeground)
                                .foregroundStyle(secondaryForeground)
                        }
                    } else {
                        Text(package.formattedPriceString)
                            .font(.system(.title3, weight: .bold))
                            .foregroundStyle(contentForeground)
                    }
                    if let slash = slashPeriodText {
                        Text(slash)
                            .font(.paywallSubtitleCondensed)
                            .foregroundStyle(secondaryForeground)
                    }
                }
            }
            .padding(layoutMetrics.adaptive(16))
            .background(
                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(16), style: .continuous)
                    .fill(cardBackground)
            )
            }
            .buttonStyle(.plain)
            .scaleEffect(isSelected ? 1.05 : 1)
            .saturation(rowSaturation)
            .opacity(rowOpacity)

            if showLaunchOfferBadge {
                LaunchOfferRowBadgeView(layoutMetrics: layoutMetrics)
                    .frame(maxWidth: .infinity)
                    .offset(y: layoutMetrics.adaptive(-12))
                    .scaleEffect(isSelected ? 1.05 : 1)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isSelected)
    }
}

// MARK: - Package Price Formatting
extension Package {
    /// Clean price string: symbol + number (e.g. "$1.99", "€1.99"). Avoids "US$" or "1,99 US$" from localizedPriceString.
    var formattedPriceString: String {
        Self.formatPrice(storeProduct.price as Decimal, currencyCode: storeProduct.currencyCode)
    }

    /// Formats a decimal price with currency symbol (symbol before number). No "US" prefix.
    static func formatPrice(_ price: Decimal, currencyCode: String?) -> String {
        let code = (currencyCode ?? "USD").uppercased()
        let symbol = currencySymbol(for: code)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = Locale.current.decimalSeparator ?? "."
        formatter.groupingSeparator = Locale.current.groupingSeparator ?? ","
        guard let formatted = formatter.string(from: price as NSDecimalNumber) else {
            return symbol + "\(price)"
        }
        return symbol + formatted
    }

    private static func currencySymbol(for code: String) -> String {
        switch code {
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        case "PLN": return "zł"
        case "RUB": return "₽"
        case "UAH": return "₴"
        default: return code + " "
        }
    }
}
