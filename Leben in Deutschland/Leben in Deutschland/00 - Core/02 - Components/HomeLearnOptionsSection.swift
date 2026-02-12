//
//  HomeLearnOptionsSection.swift
//  Leben in Deutschland
//
//  Learn section with 3 buttons: Spaced Repetition, Learn by Topics, Favorites
//

import SwiftUI

struct HomeLearnOptionsSection: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    @Environment(AppRouter.self) private var router

    var body: some View {
        SectionContainer(title: "home_learn_section_title", spacing: 18) {
            VStack(spacing: layoutMetrics.adaptive(16)) {
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
                .buttonStyle(BouncyScaleButtonStyle())
                
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
                .buttonStyle(BouncyScaleButtonStyle())
                
                Button {
                    HapticManager.shared.lightImpact()
                    router.push(.favorites)
                } label: {
                    LearnButtonContent(
                        icon: "heart.fill",
                        title: "home_learn_favorites",
                        color: Color("AppPink")
                    )
                }
                .buttonStyle(BouncyScaleButtonStyle())
            }
        }
        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
        .id(languageManager.currentAppLanguage)
    }
}

// MARK: - Learn Button Content
private struct LearnButtonContent: View {
    let icon: String
    let title: String
    let color: Color
    
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    var body: some View {
        HStack(spacing: layoutMetrics.adaptive(16)) {
            Image(systemName: icon)
                .font(.system(size: layoutMetrics.adaptive(24), weight: .semibold))
                .foregroundColor(.white)
                .frame(width: layoutMetrics.adaptive(52), height: layoutMetrics.adaptive(52))
                .background(
                    RoundedRectangle(cornerRadius: layoutMetrics.adaptive(16), style: .continuous)
                        .fill(color)
                )
            
            Text(title.localized)
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: "chevron.right")
                .font(.system(size: layoutMetrics.adaptive(14), weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(layoutMetrics.adaptive(18))
        .background(
            RoundedRectangle(cornerRadius: layoutMetrics.adaptive(20), style: .continuous)
                .fill(Color(.tertiarySystemBackground).opacity(0.9))
        )
        .contentShape(Rectangle())
    }
}

// MARK: - Preview
#Preview {
    HomeLearnOptionsSection()
        .environment(AppRouter())
        .padding()
        .background(Color(.systemBackground))
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
