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
    /// When non-nil, show eagle level-up splash. Cleared when user dismisses.
    @Published var pendingEagleLevelUp: EagleStage? = nil

    private var totalQuestions: Int
    private let manager: SpacedRepetitionManaging
    private let contentService: ContentService
    private let questionsPerSession: Int
    private let favoritesManager: FavoritesManaging
    private let stateManager: StateManager
    
    init(
        manager: SpacedRepetitionManaging? = nil,
        contentService: ContentService? = nil,
        questionsPerSession: Int = 12,
        favoritesManager: FavoritesManaging? = nil,
        stateManager: StateManager? = nil
    ) {
        self.manager = manager ?? SpacedRepetitionManager.shared
        self.contentService = contentService ?? ContentService.shared
        self.favoritesManager = favoritesManager ?? FavoritesManager.shared
        self.stateManager = stateManager ?? StateManager.shared
        
        let daysUntilTest = Self.computeDaysUntilTest()
        let sessionSize = daysUntilTest <= 3 ? 20 : (daysUntilTest <= 7 ? 16 : 12)
        self.questionsPerSession = questionsPerSession == 12 ? sessionSize : questionsPerSession
        
        let pool = self.contentService.getQuestionsForSpacedRepetition(selectedState: self.stateManager.selectedState)
        let resolved = self.manager.questionsForSession(
            from: pool,
            limit: self.questionsPerSession
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
        // Exam is always 310 questions (300 federal + 10 state-specific).
        let readinessPercentage = manager.readinessPercentage(totalQuestions: LayoutMetrics.totalFederalQuestions)
        
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
    
    /// Returns false when free user has reached the 30-question limit and cannot reveal answer.
    @discardableResult
    func handlePrimaryAction(isPro: Bool) -> Bool {
        if showCorrectAnswer {
            advanceToNextQuestion()
            return true
        }
        return revealAnswer(isPro: isPro)
    }
    
    func refreshSessionIfNeeded() {
        let availableQuestions = contentService.getQuestionsForSpacedRepetition(selectedState: stateManager.selectedState)
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
    
    @discardableResult
    func toggleFavorite(for questionId: String, isPro: Bool) -> Bool {
        let outcome = favoritesManager.toggleFavorite(for: questionId, isPro: isPro)
        if outcome == .toggled { objectWillChange.send() }
        return !outcome.shouldPresentPaywall
    }
}

private extension SpacedRepetitionViewModel {
    /// Returns false when free user has reached the 30-question limit.
    func revealAnswer(isPro: Bool) -> Bool {
        guard showCorrectAnswer == false else { return true }
        guard FreemiumUsageService.shared.canRecordSmartLearningAnswer(isPro: isPro) else {
            return false
        }
        let correctIndex = contentService.correctAnswers[currentQuestion.id]
        let isCorrect = selectedAnswer != nil && selectedAnswer == correctIndex
        manager.recordAnswer(for: currentQuestion.id, isCorrect: isCorrect)
        FreemiumUsageService.shared.recordSmartLearningAnswer()
        // Intuitive haptics: success for correct, stronger error for wrong
        if isCorrect {
            HapticManager.shared.success()
            // Check for eagle level-up (only on correct answer)
            let newReadiness = manager.readinessPercentage(totalQuestions: LayoutMetrics.totalFederalQuestions)
            if let stage = EagleLevelUpService.checkForLevelUp(newReadinessPercentage: newReadiness) {
                pendingEagleLevelUp = stage
            }
        } else {
            HapticManager.shared.errorStrong()
        }
        answeredCount = min(answeredCount + 1, totalQuestions)
        showCorrectAnswer = true
        // Trigger view update to refresh progress bar with new readiness percentage
        objectWillChange.send()
        return true
    }
    
    func advanceToNextQuestion() {
        let nextIndex = currentIndex + 1
        currentIndex = nextIndex < questions.count ? nextIndex : 0
        selectedAnswer = nil
        showCorrectAnswer = false
    }
}

private extension SpacedRepetitionViewModel {
    static func computeDaysUntilTest() -> Int {
        let testDate = OnboardingPreferences.shared.testDate
            ?? UserDefaults.standard.object(forKey: UserDefaultsKeys.selectedTestDate) as? Date
        guard let date = testDate else { return LayoutMetrics.maxHorizonDays }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return min(max(0, days), LayoutMetrics.maxHorizonDays)
    }
    
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
            hint: nil,
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
            hint: nil,
            category: nil,
            subcategory: nil
        )
    ]
}

