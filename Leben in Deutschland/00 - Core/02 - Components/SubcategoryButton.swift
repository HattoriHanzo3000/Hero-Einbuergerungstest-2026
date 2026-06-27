//
//  SubcategoryButton.swift
//  Leben in Deutschland
//
//  Subcategory row with progress bar. Navigates to LearningView.
//  Used by ExpandableCategoryView in CategoriesView.
//

import SwiftUI

// MARK: - Subcategory Button
struct SubcategoryButton: View {
    let subcategory: SubcategoryModel
    let isFreeTopicBlock: Bool
    @ObservedObject var answersService: AnswersService
    @Environment(AppRouter.self) private var router
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @State private var isPressed = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.layoutMetrics) private var layoutMetrics

    var body: some View {
        let completionPercentage = answersService.getCompletionPercentage(for: subcategory)
        let rowHeight = rowHeightForDynamicType()
        let horizontalPadding = horizontalPaddingForDynamicType()

        Button {
            HapticManager.shared.lightImpact()
            if isFreeTopicBlock || subscriptionManager.effectiveIsPro {
                router.push(.learning(
                    subcategoryName: subcategory.name,
                    categoryName: subcategory.categoryName
                ))
            } else {
                subscriptionManager.presentProLimitSheet(
                    titleKey: "limit_topic_pro_title",
                    messageKey: "limit_topic_pro_message",
                    accentColorName: "AppCaribean"
                )
            }
        } label: {
            HStack(alignment: .center, spacing: 12) {
                Text(subcategory.name)
                    .font(.system(.title2, weight: .light).width(.condensed))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(subcategory.questionCount)")
                    .font(.system(.title2, weight: .regular).width(.expanded))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 8)
            .frame(minHeight: rowHeight)
            .padding(.horizontal, horizontalPadding)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color(.systemGray3))

                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color("AppCaribean"))
                            .frame(width: geometry.size.width * completionPercentage)
                    }
                }
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(NoEffectButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .buttonPressAnimation(isPressed: $isPressed)
        .padding(.horizontal, 8)
    }

    private func rowHeightForDynamicType() -> CGFloat {
        let base: CGFloat
        switch dynamicTypeSize {
        case .xSmall, .small, .medium: base = 55
        case .large: base = 60
        case .xLarge: base = 68
        case .xxLarge, .xxxLarge: base = 76
        default: base = 84
        }
        return layoutMetrics.adaptive(base)
    }

    private func horizontalPaddingForDynamicType() -> CGFloat {
        let base: CGFloat
        switch dynamicTypeSize {
        case .xSmall, .small, .medium: base = 16
        case .large: base = 18
        case .xLarge: base = 20
        default: base = 22
        }
        return layoutMetrics.adaptive(base)
    }
}
