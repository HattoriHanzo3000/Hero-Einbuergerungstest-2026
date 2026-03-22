//
//  SearchQuestionCard.swift
//  Leben in Deutschland
//
//  Search result card showing question text, optional translation, and metadata.
//  Used by SearchView in SearchTabView.
//

import SwiftUI

// MARK: - Search Question Card
struct SearchQuestionCard: View {
    let question: QuestionModel
    let subcategoryName: String
    let categoryName: String
    let matchedByTranslation: Bool
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @State private var isPressed = false
    @State private var navigateToLearning = false

    private var translatedQuestion: QuestionModel? {
        guard matchedByTranslation else { return nil }
        return ContentService.shared.getTranslatedQuestion(id: question.id)
    }

    private var canStudyTopic: Bool {
        TopicAccessPolicy.isFreeCategory(categoryName: categoryName, categories: ContentService.shared.categories)
            || subscriptionManager.effectiveIsPremium
    }

    var body: some View {
        Button {
            HapticManager.shared.lightImpact()
            if canStudyTopic {
                navigateToLearning = true
            } else {
                subscriptionManager.presentPremiumLimitSheet(
                    titleKey: "limit_topic_premium_title",
                    messageKey: "limit_topic_premium_message",
                    accentColorName: "AppCaribean"
                )
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(question.text)
                    .font(.callout.weight(.semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)

                if matchedByTranslation, let translated = translatedQuestion, translated.text != question.text {
                    Text(translated.text)
                        .font(.system(.footnote))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .padding(.top, 4)
                }

                HStack(spacing: 8) {
                    Text("question_label".localized + " \(question.id)")
                        .font(.caption.weight(.semibold))
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    Text(subcategoryName)
                        .font(.caption)
                        .fontDesign(.rounded)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .buttonPressAnimation(isPressed: $isPressed)
        .background(
            NavigationLink(
                destination: LearningView(subcategory: SubcategoryModel(
                    name: subcategoryName,
                    categoryName: categoryName,
                    questions: [question]
                ), usesRouterNavigation: false).environmentObject(languageManager),
                isActive: $navigateToLearning
            ) { EmptyView() }
        )
    }
}
