//
//  PaywallPackageRow.swift
//  Leben in Deutschland
//
//  Package row UI for paywall: plan selection, trial badge, price formatting.
//

import SwiftUI
import RevenueCat

// MARK: - Trial Shield Badge
/// Orange "3 days free trial" badge with subtle zoom pulse and rounded corners.
private struct TrialShieldBadgeView: View {
    let layoutMetrics: LayoutMetrics

    @State private var scale: CGFloat = 1.0

    private let cornerRadius: CGFloat = 12

    var body: some View {
        Text("paywall_trial_shield".localized)
            .font(.system(.caption2, weight: .semibold).italic())
            .foregroundStyle(.white)
            .padding(.horizontal, layoutMetrics.adaptive(8))
            .padding(.vertical, layoutMetrics.adaptive(5))
            .background(Color("AppOrange").opacity(1))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .scaleEffect(scale)
            .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    scale = 1.06
                }
            }
    }
}

// MARK: - Paywall Package Row
struct PaywallPackageRow: View {
    let package: Package
    let isSelected: Bool
    let onSelect: () -> Void

    @Environment(\.layoutMetrics) private var layoutMetrics

    private var planTitle: String {
        switch package.packageType {
        case .monthly: return "premium_plan_monthly".localized
        case .annual: return "premium_plan_yearly".localized
        case .lifetime: return "premium_plan_lifetime".localized
        case .sixMonth: return "premium_plan_six_month".localized
        case .threeMonth: return "premium_plan_three_month".localized
        case .twoMonth: return "premium_plan_two_month".localized
        case .weekly: return "premium_plan_weekly".localized
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

    /// Best value badge: annual only (not lifetime).
    private var isLimitedOffer: Bool {
        package.packageType == .annual
    }

    /// Plan subtitle: Monthly, 3 Months, Lifetime.
    private var planSubtitle: String? {
        switch package.packageType {
        case .monthly: return "paywall_subtitle_monthly".localized
        case .threeMonth:
            let price = package.storeProduct.price as Decimal
            let perMonth = price / 3
            let formatted = Package.formatPrice(perMonth, currencyCode: package.storeProduct.currencyCode)
            return String(format: "paywall_subtitle_3_months_format".localized, formatted)
        case .lifetime: return "paywall_subtitle_lifetime".localized
        default: return nil
        }
    }

    private var contentForeground: Color { isSelected ? .white : .primary }
    private var secondaryForeground: Color { isSelected ? .white.opacity(0.9) : .secondary }

    /// Small orange shield badge for 3-month plan: straddles the top border. Subtle zoom pulse, no shimmer.
    private var trialShieldBadge: some View {
        TrialShieldBadgeView(layoutMetrics: layoutMetrics)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Button(action: onSelect) {
                HStack(spacing: layoutMetrics.adaptive(12)) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: layoutMetrics.adaptive(24), weight: .semibold))
                    .foregroundStyle(isSelected ? .white : .secondary)

                VStack(alignment: .leading, spacing: layoutMetrics.adaptive(2)) {
                    HStack(spacing: layoutMetrics.adaptive(8)) {
                        Text(planTitle)
                            .font(.system(.headline, weight: .bold))
                            .foregroundStyle(contentForeground)
                        if isLimitedOffer {
                            Text("paywall_best_value".localized)
                                .font(.system(.caption2, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(isSelected ? Color.white.opacity(0.25) : Color("AppOrange"))
                                .clipShape(Capsule())
                        }
                    }
                    if let text = planSubtitle {
                        Text(text)
                            .font(.system(.caption))
                            .foregroundStyle(secondaryForeground)
                    }
                }

                Spacer(minLength: 8)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(package.formattedPriceString)
                        .font(.system(.title3, weight: .bold))
                        .foregroundStyle(contentForeground)
                    if let slash = slashPeriodText {
                        Text(slash)
                            .font(.system(.caption))
                            .foregroundStyle(secondaryForeground)
                    }
                }
            }
            .padding(layoutMetrics.adaptive(16))
            .background(
                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(16), style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(LiquidGlassGradient.blue.screenBackground) : AnyShapeStyle(Color(.systemBackground)))
            )
            }
            .buttonStyle(.plain)
            .scaleEffect(isSelected ? 1.05 : 1)
            .opacity(isSelected ? 1 : 0.55)

            if package.packageType == .threeMonth {
                trialShieldBadge
                    .offset(y: layoutMetrics.adaptive(-12))
                    .frame(maxWidth: .infinity)
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
