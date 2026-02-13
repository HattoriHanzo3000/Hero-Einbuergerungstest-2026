//
//  ExpandableCategoryView.swift
//  Leben in Deutschland
//
//  Expandable category card with icon, completion state, and subcategory list.
//  Used by CategoriesView.
//

import SwiftUI

// MARK: - Expandable Category View
struct ExpandableCategoryView: View {
    let category: CategoryModel
    let isExpanded: Bool
    let onToggle: () -> Void
    @ObservedObject var answersService: AnswersService
    @State private var isPressed = false
    @State private var iconWiggle: Double = 0
    @State private var wiggleTrigger = 0
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.layoutMetrics) private var layoutMetrics

    private var isCategoryCompleted: Bool {
        category.subcategories.allSatisfy { subcategory in
            answersService.getCompletionPercentage(for: subcategory) >= 1.0
        }
    }

    private var categoryIcon: String {
        CategoryIconMapping.icon(for: category.name)
    }

    private var containerPadding: CGFloat {
        let base: CGFloat
        switch dynamicTypeSize {
        case .xSmall, .small, .medium: base = 16
        case .large: base = 18
        case .xLarge: base = 20
        default: base = 22
        }
        return layoutMetrics.adaptive(base)
    }

    private var categoryGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppCaribean").opacity(0.72),
                Color("AppCaribean").opacity(0.52)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var categoryBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppCaribean").opacity(0.14),
                Color("AppCaribean").opacity(0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func runWiggleAnimation() {
        let duration: Double = 0.07
        withAnimation(.easeInOut(duration: duration)) { iconWiggle = -8 }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.easeInOut(duration: duration)) { iconWiggle = 8 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration * 2) {
            withAnimation(.easeInOut(duration: duration)) { iconWiggle = -4 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration * 3) {
            withAnimation(.easeInOut(duration: duration)) { iconWiggle = 0 }
        }
    }

    @ViewBuilder
    private var categoryIconView: some View {
        let image = Image(systemName: categoryIcon)
            .font(.system(.title, design: .rounded).weight(.semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)

        if #available(iOS 18.0, *) {
            image
                .symbolEffect(.wiggle.byLayer, options: .default, value: wiggleTrigger)
                .onChange(of: isExpanded) { _, newValue in
                    if newValue { wiggleTrigger += 1 }
                }
        } else {
            image
                .rotationEffect(.degrees(iconWiggle))
                .onChange(of: isExpanded) { _, newValue in
                    if newValue {
                        runWiggleAnimation()
                    } else {
                        withAnimation(.easeOut(duration: 0.1)) { iconWiggle = 0 }
                    }
                }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                HapticManager.shared.lightImpact()
                onToggle()
            }) {
                VStack(alignment: .leading, spacing: 12) {
                    categoryIconView

                    HStack(spacing: 12) {
                        Text(category.name)
                            .font(.system(.title, weight: .regular).width(.condensed))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if isCategoryCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.9))
                                .accessibilityLabel("Category completed")
                        }

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, containerPadding)
                .padding(.horizontal, containerPadding)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(categoryGradient)
                )
            }
            .contentShape(Rectangle())
            .buttonStyle(.plain)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .buttonPressAnimation(isPressed: $isPressed)

            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(category.subcategories) { subcategory in
                        SubcategoryButton(
                            subcategory: subcategory,
                            answersService: answersService
                        )
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(categoryBackgroundGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.45), Color.white.opacity(0.12)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.6
                )
        )
    }
}
