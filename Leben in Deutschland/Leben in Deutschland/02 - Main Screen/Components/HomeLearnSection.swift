//
//  HomeLearnSection.swift
//  Leben in Deutschland
//
//  Learn section with 3 buttons: Spaced Repetition, Learn by Topics, Favorites
//

import SwiftUI

struct HomeLearnSection: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    @Environment(AppRouter.self) private var router
    @EnvironmentObject private var premiumManager: PremiumManager
    
    @State private var showPremiumAlert = false
    
    var body: some View {
        SectionContainer(title: "home_learn_section_title") {
            VStack(spacing: layoutMetrics.adaptive(12)) {
                Button {
                    HapticManager.shared.lightImpact()
                    router.push(.spacedRepetition)
                } label: {
                    LearnButtonContent(
                        icon: "arrow.triangle.2.circlepath",
                        title: "home_learn_spaced_repetition",
                        color: Color("AppBlueLagoon")
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button {
                    HapticManager.shared.lightImpact()
                    router.push(.categories)
                } label: {
                    LearnButtonContent(
                        icon: "book.fill",
                        title: "home_learn_by_topics",
                        color: Color("AppCaribean")
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button {
                    HapticManager.shared.lightImpact()
                    if premiumManager.isPremium {
                        router.push(.favorites)
                    } else {
                        showPremiumAlert = true
                    }
                } label: {
                    LearnButtonContent(
                        icon: "heart.fill",
                        title: "home_learn_favorites",
                        color: Color("AppPink"),
                        isLocked: !premiumManager.isPremium
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .alert("premium_favorites_alert_title".localized, isPresented: $showPremiumAlert) {
                    Button("premium_favorites_alert_cancel".localized, role: .cancel) { }
                    Button("premium_favorites_alert_upgrade".localized) {
                        router.push(.premium)
                    }
                } message: {
                    Text("premium_favorites_alert_message".localized)
                }
            }
        }
    }
}

// MARK: - Learn Button Content
private struct LearnButtonContent: View {
    let icon: String
    let title: String
    let color: Color
    var isLocked: Bool = false
    
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    var body: some View {
        HStack(spacing: layoutMetrics.adaptive(16)) {
            ZStack {
                Image(systemName: icon)
                    .font(.system(size: layoutMetrics.adaptive(24), weight: .semibold))
                    .foregroundColor(.white)
                    .opacity(isLocked ? 0.5 : 1.0)
                
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: layoutMetrics.adaptive(14), weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: layoutMetrics.adaptive(12), y: -layoutMetrics.adaptive(12))
                }
            }
            .frame(width: layoutMetrics.adaptive(48), height: layoutMetrics.adaptive(48))
            .background(
                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(12), style: .continuous)
                    .fill(color)
            )
            
            Text(title.localized)
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: "chevron.right")
                .font(.system(size: layoutMetrics.adaptive(14), weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(layoutMetrics.adaptive(16))
        .background(
            RoundedRectangle(cornerRadius: layoutMetrics.adaptive(16), style: .continuous)
                .fill(Color(.systemGray6).opacity(0.4))
        )
        .contentShape(Rectangle())
    }
}

// MARK: - Preview
#Preview {
    HomeLearnSection()
        .environment(AppRouter())
        .padding()
        .background(Color(.systemBackground))
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

