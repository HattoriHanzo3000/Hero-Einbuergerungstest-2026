import SwiftUI

/// Entry point for the Premium experience presented from the main tab bar.
/// Displays premium features comparison and subscription options.
struct PremiumHubView: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var premiumManager: PremiumManager
    @State private var showingSubscriptionOptions = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: layoutMetrics.adaptive(32)) {
                        // Header message
                        VStack(spacing: layoutMetrics.adaptive(16)) {
                Image(systemName: "crown.fill")
                                .font(.system(size: layoutMetrics.adaptive(64), weight: .semibold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color("AppOrange"), Color(red: 0.77, green: 0.21, blue: 0.12)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                    .accessibilityHidden(true)

                            Text("premium_unlock_message".localized)
                                .font(.system(.title, design: .rounded).weight(.bold))
                                .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                                .padding(.horizontal, layoutMetrics.adaptive(24))
                        }
                        .padding(.top, geometry.safeAreaInsets.top + layoutMetrics.adaptive(32))
                        .padding(.bottom, layoutMetrics.adaptive(24))
                        
                        // Trial status banner (if trial is active)
                        if premiumManager.isTrialActive {
                            TrialStatusBanner(daysRemaining: premiumManager.trialDaysRemaining)
                                .padding(.horizontal, layoutMetrics.adaptive(24))
                        }
                        
                        // Comparison table
                        PremiumComparisonTable()
                            .padding(.horizontal, layoutMetrics.adaptive(20))
                        
                        // Subscribe button
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            showingSubscriptionOptions = true
                        }) {
                            Text("premium_subscribe_now".localized)
                                .font(.system(.headline, design: .rounded).weight(.bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: layoutMetrics.adaptive(56))
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color("AppOrange"),
                                            Color(red: 0.77, green: 0.21, blue: 0.12)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(layoutMetrics.adaptive(16))
                                .shadow(color: Color("AppOrange").opacity(0.3), radius: 12, y: 6)
                        }
                        .padding(.horizontal, layoutMetrics.adaptive(24))
                        .padding(.bottom, layoutMetrics.adaptive(32) + geometry.safeAreaInsets.bottom)
                    }
                }
                .background(Color(.systemBackground))
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingSubscriptionOptions) {
                SubscriptionOptionsView()
            }
        }
    }
}

#Preview("Premium Hub View") {
    PremiumHubView()
        .environmentObject(LanguageManager())
        .environmentObject(PremiumManager.shared)
}

