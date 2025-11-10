//
//  QuestionCard.swift
//  Leben in Deutschland
//
//  Component for displaying a question with answer options
//

import SwiftUI

struct QuestionCard: View {
    let question: QuestionModel
    let selectedAnswer: Int?
    let showCorrectAnswer: Bool
    let showTranslation: Bool
    let onAnswerSelected: (Int) -> Void
    
    @EnvironmentObject var languageManager: LanguageManager
    @State private var translatedQuestion: QuestionModel?
    
    var body: some View {
        VStack(spacing: 20) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Question text
                    Text(question.text)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Translation (if enabled)
                    if showTranslation, let translated = translatedQuestion {
                        if translated.text != question.text {
                            Text(translated.text)
                                .font(.footnote)
                                .fontDesign(.rounded)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 8)
                        }
                    }
                    
                    // TODO: Add question image/illustration support
                    
                    // Answer options
                    VStack(spacing: 12) {
                        ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                            Button(action: {
                                if !showCorrectAnswer {
                                    onAnswerSelected(index)
                                }
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(option)
                                        .font(.callout)
                                        .fontDesign(.rounded)
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    // Translation for answer option (if enabled)
                                    if showTranslation, let translated = translatedQuestion {
                                        if index < translated.options.count && translated.options[index] != option {
                                            Text(translated.options[index])
                                                .font(.footnote)
                                                .fontDesign(.rounded)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(answerBackgroundColor(for: index))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
        }
        .background(Color(.systemBackground))
        .task(id: "\(question.id)-\(showTranslation)") {
            if showTranslation {
                await loadTranslation()
            } else {
                translatedQuestion = nil
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadTranslation() async {
        let translationLanguage = languageManager.currentTranslationLanguage
        guard translationLanguage != languageManager.currentAppLanguage else {
            translatedQuestion = nil
            return
        }
        
        translatedQuestion = await ContentService.shared.getQuestion(id: question.id, in: translationLanguage)
    }
    
    private func isCorrectAnswer(_ index: Int) -> Bool {
        let correctAnswers = ContentService.shared.correctAnswers
        guard let correctIndex = correctAnswers[question.id] else { return false }
        return index == correctIndex
    }
    
    private func answerBackgroundColor(for index: Int) -> Color {
        guard showCorrectAnswer else {
             return selectedAnswer == index ? Color("Selected") : Color("Unselected")
        }
        
        // When showing correct answer
        if isCorrectAnswer(index) {
            return Color("Correct")
        } else if index == selectedAnswer {
            return Color("Wrong")
        } else {
            return Color("Unselected")
        }
    }
}

