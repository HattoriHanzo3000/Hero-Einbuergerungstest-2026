//
//  SubscriptionOptionsView.swift
//  Leben in Deutschland
//
//  View for selecting subscription plan (Monthly or Lifetime)
//

import SwiftUI

struct SubscriptionOptionsView: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var premiumManager: PremiumManager
    
    @State private var selectedPlan: SubscriptionPlanType? = nil
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: layoutMetrics.adaptive(32)) {
                    // Header
                    VStack(spacing: layoutMetrics.adaptive(16)) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: layoutMetrics.adaptive(56), weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color("AppOrange"), Color(red: 0.77, green: 0.21, blue: 0.12)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .accessibilityHidden(true)
                        
                        Text("premium_unlock_title".localized)
                            .font(.system(.title, design: .rounded).weight(.bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("premium_unlock_description".localized)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, layoutMetrics.adaptive(24))
                    }
                    .padding(.top, geometry.safeAreaInsets.top + layoutMetrics.adaptive(32))
                    .padding(.bottom, layoutMetrics.adaptive(8))
                    
                    // Trial offer banner (if trial is available)
                    if premiumManager.isTrialAvailable {
                        TrialOfferBanner()
                            .padding(.horizontal, layoutMetrics.adaptive(24))
                    }
                    
                    // Subscription options
                    VStack(spacing: layoutMetrics.adaptive(20)) {
                        // Monthly plan
                        SubscriptionPlanCard(
                            plan: .monthlyPlan,
                            isSelected: selectedPlan == .monthly,
                            showTrialBadge: premiumManager.isTrialAvailable && selectedPlan == .monthly,
                            onSelect: {
                                HapticManager.shared.lightImpact()
                                selectedPlan = .monthly
                            }
                        )
                        
                        // Lifetime plan
                        SubscriptionPlanCard(
                            plan: .lifetimePlan,
                            isSelected: selectedPlan == .lifetime,
                            showTrialBadge: false,
                            onSelect: {
                                HapticManager.shared.lightImpact()
                                selectedPlan = .lifetime
                            }
                        )
                    }
                    .padding(.horizontal, layoutMetrics.adaptive(24))
                    
                    // Subscription terms
                    if let selectedPlan = selectedPlan {
                        SubscriptionTermsView(planType: selectedPlan)
                            .padding(.horizontal, layoutMetrics.adaptive(24))
                    }
                    
                    // Continue button
                    Button(action: {
                        HapticManager.shared.mediumImpact()
                        // TODO: Implement StoreKit purchase logic
                        if let plan = selectedPlan {
                            // Start trial if available (for monthly subscription)
                            if plan == .monthly && premiumManager.isTrialAvailable {
                                premiumManager.startFreeTrial()
                            }
                            // For now, simulate successful purchase
                            // In production, replace this with actual StoreKit purchase flow
                            handlePurchase(plan: plan)
                        }
                    }) {
                        Group {
                            if let plan = selectedPlan, plan == .monthly && premiumManager.isTrialAvailable {
                                Text("premium_start_trial".localized)
                            } else {
                                Text("premium_continue".localized)
                            }
                        }
                            .font(.system(.headline, design: .rounded).weight(.bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: layoutMetrics.adaptive(56))
                            .background(
                                Group {
                                    if selectedPlan != nil {
                                        LinearGradient(
                                            colors: [
                                                Color("AppOrange"),
                                                Color(red: 0.77, green: 0.21, blue: 0.12)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    } else {
                                        LinearGradient(
                                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    }
                                }
                            )
                            .cornerRadius(layoutMetrics.adaptive(16))
                            .shadow(
                                color: selectedPlan != nil ? Color("AppOrange").opacity(0.3) : Color.clear,
                                radius: 12,
                                y: 6
                            )
                    }
                    .disabled(selectedPlan == nil)
                    .padding(.horizontal, layoutMetrics.adaptive(24))
                    .padding(.bottom, layoutMetrics.adaptive(32) + geometry.safeAreaInsets.bottom)
                }
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Purchase Handling
    
    private func handlePurchase(plan: SubscriptionPlanType) {
        // TODO: Replace with actual StoreKit purchase flow
        // This is a placeholder for when StoreKit is integrated
        
        let expiryDate: Date?
        if plan == .monthly {
            // Monthly subscription expires in 1 month
            expiryDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        } else {
            // Lifetime never expires
            expiryDate = nil
        }
        
        premiumManager.activateSubscription(type: plan, expiryDate: expiryDate)
        dismiss()
        
        // Show success message or navigate to success screen
        // You can add a completion handler or use a published property for this
    }
}

// MARK: - Subscription Plan Card
private struct SubscriptionPlanCard: View {
    let plan: SubscriptionPlanModel
    let isSelected: Bool
    let showTrialBadge: Bool
    let onSelect: () -> Void
    
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: layoutMetrics.adaptive(16)) {
                VStack(alignment: .leading, spacing: layoutMetrics.adaptive(8)) {
                    // Plan title and badge
                    HStack(spacing: layoutMetrics.adaptive(8)) {
                        Text(plan.type == .monthly ? "premium_plan_monthly".localized : "premium_plan_lifetime".localized)
                            .font(.system(.headline, design: .rounded).weight(.bold))
                            .foregroundColor(.primary)
                        
                        if showTrialBadge {
                            Text("premium_trial_badge".localized)
                                .font(.system(.caption, design: .rounded).weight(.semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, layoutMetrics.adaptive(8))
                                .padding(.vertical, layoutMetrics.adaptive(4))
                                .background(Color.green)
                                .cornerRadius(layoutMetrics.adaptive(8))
                        } else if plan.isLimitedOffer {
                            Text("premium_limited_offer".localized)
                                .font(.system(.caption, design: .rounded).weight(.semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, layoutMetrics.adaptive(8))
                                .padding(.vertical, layoutMetrics.adaptive(4))
                                .background(Color("AppOrange"))
                                .cornerRadius(layoutMetrics.adaptive(8))
                        }
                    }
                    
                    // Price
                    HStack(alignment: .firstTextBaseline, spacing: layoutMetrics.adaptive(4)) {
                        Text("\(plan.price) €")
                            .font(.system(.title2, design: .rounded).weight(.bold))
                            .foregroundColor(.primary)
                        
                        if let periodKey = plan.periodKey {
                            Text(periodKey.localized)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Original price (if applicable)
                    if let originalPrice = plan.originalPrice {
                        HStack(spacing: layoutMetrics.adaptive(4)) {
                            Text("premium_regular_price".localized)
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            Text("\(originalPrice) €")
                                .font(.system(.caption, design: .rounded))
                                .strikethrough()
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: layoutMetrics.adaptive(24), weight: .semibold))
                    .foregroundColor(isSelected ? Color("AppOrange") : .secondary)
            }
            .padding(layoutMetrics.adaptive(20))
            .background(
                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(16), style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(16), style: .continuous)
                            .stroke(
                                isSelected ? Color("AppOrange") : Color(.separator).opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: isSelected ? Color("AppOrange").opacity(0.2) : Color.black.opacity(0.05),
                radius: isSelected ? 8 : 4,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Subscription Terms View
private struct SubscriptionTermsView: View {
    let planType: SubscriptionPlanType
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    var body: some View {
        VStack(alignment: .leading, spacing: layoutMetrics.adaptive(8)) {
            if planType == .monthly {
                Text("premium_terms_monthly_part1".localized.replacingOccurrences(of: "{price}", with: "2,99"))
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("premium_terms_common".localized)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("premium_terms_lifetime_part1".localized.replacingOccurrences(of: "{price}", with: "9,99"))
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("premium_terms_lifetime_common".localized)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(layoutMetrics.adaptive(16))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: layoutMetrics.adaptive(12), style: .continuous)
                .fill(Color(.secondarySystemBackground).opacity(0.5))
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SubscriptionOptionsView()
    }
    .environmentObject(LanguageManager())
}

