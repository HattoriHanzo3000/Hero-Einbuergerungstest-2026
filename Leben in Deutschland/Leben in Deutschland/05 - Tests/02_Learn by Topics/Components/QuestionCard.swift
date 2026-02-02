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
    let illustrationAssetName: String?
    let onImageTapped: (() -> Void)?
    
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    @State private var translatedQuestion: QuestionModel?
    
    init(
        question: QuestionModel,
        selectedAnswer: Int?,
        showCorrectAnswer: Bool,
        showTranslation: Bool,
        onAnswerSelected: @escaping (Int) -> Void,
        illustrationAssetName: String? = nil,
        onImageTapped: (() -> Void)? = nil
    ) {
        self.question = question
        self.selectedAnswer = selectedAnswer
        self.showCorrectAnswer = showCorrectAnswer
        self.showTranslation = showTranslation
        self.onAnswerSelected = onAnswerSelected
        self.illustrationAssetName = illustrationAssetName
        self.onImageTapped = onImageTapped
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Question illustration
                    if let assetName = illustrationAssetName {
                        Image(assetName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: 280)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onImageTapped?()
                            }
                    }
                    
                    // Question text
                    Text(question.text)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Translation (if enabled)
                    if showTranslation, let translated = translatedQuestion {
                        if translated.text != question.text {
                            Text(translated.text)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 8)
                        }
                    }
                    
                    // Answer options
                    VStack(spacing: 12) {
                        ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                            QuizAnswerOptionButton(
                                primaryText: option,
                                secondaryText: secondaryOptionText(for: index, original: option),
                                state: answerState(for: index),
                                accessibilityLabel: accessibilityLabel(for: index, option: option)
                            ) {
                                if showCorrectAnswer == false {
                                    onAnswerSelected(index)
                                }
                                }
                        }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 8)
                .padding(.bottom, 24)
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
    
}

private extension QuestionCard {
    func secondaryOptionText(for index: Int, original: String) -> String? {
        guard showTranslation, let translated = translatedQuestion else { return nil }
        guard index < translated.options.count else { return nil }
        let translatedOption = translated.options[index]
        return translatedOption == original ? nil : translatedOption
    }
    
    func answerState(for index: Int) -> QuizAnswerOptionButton.State {
        if showCorrectAnswer {
            if isCorrectAnswer(index) {
                return .correct
            }
            if index == selectedAnswer {
                return .incorrect
            }
            return .neutral
        }
        return selectedAnswer == index ? .selected : .neutral
        }
        
    func accessibilityLabel(for index: Int, option: String) -> String {
        if let secondary = secondaryOptionText(for: index, original: option) {
            return "\(option). \(secondary)"
        }
        return option
    }
}

