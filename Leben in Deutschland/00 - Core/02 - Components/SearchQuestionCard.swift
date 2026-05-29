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
    private var translatedQuestion: QuestionModel? {
        guard matchedByTranslation else { return nil }
        return ContentService.shared.getTranslatedQuestion(id: question.id)
    }

    var body: some View {
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
        .padding(.vertical, 8)
    }
}
