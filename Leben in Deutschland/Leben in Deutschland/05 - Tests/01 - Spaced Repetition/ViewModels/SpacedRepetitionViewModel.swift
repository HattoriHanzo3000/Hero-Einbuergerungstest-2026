import SwiftUI
import Combine

// MARK: - Spaced Repetition View Model
/// Coordinates the state for the spaced repetition practice session.
final class SpacedRepetitionViewModel: ObservableObject {
    @Published private(set) var questions: [QuestionModel] = []
    @Published private(set) var currentIndex: Int = 0
    @Published var selectedAnswer: Int?
    @Published var showCorrectAnswer = false
    @Published var showTranslation = false
    @Published private(set) var answeredCount: Int = 0
    
    private var totalQuestions: Int
    private let manager: SpacedRepetitionManaging
    private let contentService: ContentService
    private let questionsPerSession: Int
    private let favoritesManager: FavoritesManaging
    
    init(
        manager: SpacedRepetitionManaging? = nil,
        contentService: ContentService? = nil,
        questionsPerSession: Int = 12,
        favoritesManager: FavoritesManaging? = nil
    ) {
        self.manager = manager ?? SpacedRepetitionManager.shared
        self.contentService = contentService ?? ContentService.shared
        self.questionsPerSession = questionsPerSession
        self.favoritesManager = favoritesManager ?? FavoritesManager.shared
        
        let resolved = self.manager.questionsForSession(
            from: self.contentService.getAllQuestions(),
            limit: questionsPerSession
        )
        
        let fallbacks = resolved.isEmpty ? SpacedRepetitionViewModel.placeholderQuestions : resolved
        self.questions = fallbacks
        self.totalQuestions = fallbacks.count
        
        if resolved.isEmpty {
            Task {
                await self.contentService.loadContent(for: LanguageManager.currentAppLanguageCode)
                await HintService.shared.loadHints(for: LanguageManager.currentAppLanguageCode)
                await MainActor.run {
                    self.refreshSessionIfNeeded()
                }
            }
        }
    }
    
    var currentQuestion: QuestionModel {
        questions[currentIndex]
    }
    
    var progressState: SpacedRepetitionQuestionCard.ProgressState {
        // Calculate overall readiness percentage (same as main screen)
        // This shows the user's overall progress from 0% to 100%
        let totalFederalQuestions = LayoutMetrics.totalFederalQuestions
        let readinessPercentage = manager.readinessPercentage(totalQuestions: totalFederalQuestions)
        
        return .init(
            answeredCount: readinessPercentage,
            totalCount: 100
        )
    }
    
    var isPrimaryButtonEnabled: Bool {
        if showCorrectAnswer {
            return true
        }
        return selectedAnswer != nil
    }
    
    func selectAnswer(_ index: Int) {
        guard showCorrectAnswer == false else { return }
        selectedAnswer = index
        if contentService.correctAnswers[currentQuestion.id] == nil {
            Task {
                await contentService.loadContent(for: LanguageManager.currentAppLanguageCode)
                await HintService.shared.loadHints(for: LanguageManager.currentAppLanguageCode)
            }
        }
    }
    
    func toggleTranslation() {
            showTranslation.toggle()
    }
    
    func handlePrimaryAction() {
        if showCorrectAnswer {
            advanceToNextQuestion()
        } else {
            revealAnswer()
        }
    }
    
    func refreshSessionIfNeeded() {
        let availableQuestions = contentService.getAllQuestions()
        guard availableQuestions.isEmpty == false else { return }
        let sessionQuestions = manager.questionsForSession(from: availableQuestions, limit: questionsPerSession)
        guard sessionQuestions.isEmpty == false else { return }
        questions = sessionQuestions
        totalQuestions = sessionQuestions.count
        currentIndex = 0
        selectedAnswer = nil
        showCorrectAnswer = false
        answeredCount = 0
    }
    
    func isFavorite(questionId: String) -> Bool {
        favoritesManager.isFavorite(questionId)
    }
    
    func toggleFavorite(for questionId: String) {
        favoritesManager.toggleFavorite(for: questionId)
        objectWillChange.send()
    }
}

private extension SpacedRepetitionViewModel {
    func revealAnswer() {
        guard showCorrectAnswer == false else { return }
        let correctIndex = contentService.correctAnswers[currentQuestion.id]
        let isCorrect = selectedAnswer != nil && selectedAnswer == correctIndex
        manager.recordAnswer(for: currentQuestion.id, isCorrect: isCorrect)
        answeredCount = min(answeredCount + 1, totalQuestions)
        showCorrectAnswer = true
        // Trigger view update to refresh progress bar with new readiness percentage
        objectWillChange.send()
    }
    
    func advanceToNextQuestion() {
        let nextIndex = currentIndex + 1
        currentIndex = nextIndex < questions.count ? nextIndex : 0
        selectedAnswer = nil
        showCorrectAnswer = false
    }
}

private extension SpacedRepetitionViewModel {
    static let placeholderQuestions: [QuestionModel] = [
        QuestionModel(
            id: "spaced_placeholder_001",
            text: "Welches Grundgesetz garantiert die Glaubens- und Gewissensfreiheit in Deutschland?",
            options: [
                "Artikel 4 des Grundgesetzes",
                "Artikel 20 des Grundgesetzes",
                "Artikel 1 des Grundgesetzes",
                "Artikel 6 des Grundgesetzes"
            ],
            category: nil,
            subcategory: nil
        ),
        QuestionModel(
            id: "spaced_placeholder_002",
            text: "Wie viele Bundesländer hat die Bundesrepublik Deutschland?",
            options: [
                "14",
                "15",
                "16",
                "17"
            ],
            category: nil,
            subcategory: nil
        )
    ]
}

