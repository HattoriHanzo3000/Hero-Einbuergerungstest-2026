//
//  SearchQuestionCard.swift
//  Leben in Deutschland
//
//  Search result card showing question text, optional translation, and metadata.
//  Used by CategoriesView in search mode.
//

import SwiftUI

// MARK: - Search Question Card
struct SearchQuestionCard: View {
    let question: QuestionModel
    let subcategoryName: String
    let matchedByTranslation: Bool
    @EnvironmentObject var languageManager: LanguageManager
    @State private var isPressed = false

    private var translatedQuestion: QuestionModel? {
        guard matchedByTranslation else { return nil }
        return ContentService.shared.getTranslatedQuestion(id: question.id)
    }

    var body: some View {
        NavigationLink(destination: LearningView(subcategory: SubcategoryModel(
            name: subcategoryName,
            categoryName: "",
            questions: [question]
        ), usesRouterNavigation: false).environmentObject(languageManager)) {
            VStack(alignment: .leading, spacing: 8) {
                Text(question.text)
                    .font(.callout.weight(.semibold))
                    .fontDesign(.rounded)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)

                if matchedByTranslation, let translated = translatedQuestion, translated.text != question.text {
                    Text(translated.text)
                        .font(.system(.footnote, design: .rounded))
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
    }
}
