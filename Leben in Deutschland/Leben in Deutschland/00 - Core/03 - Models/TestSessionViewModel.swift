//
//  TestSessionViewModel.swift
//  Leben in Deutschland
//
//  ViewModel managing test session state, timer, and answers
//

import Foundation
import Combine

@MainActor
class TestSessionViewModel: ObservableObject {
    @Published private(set) var questions: [TestQuestion] = []
    @Published private(set) var answers: [TestUserAnswer] = []
    @Published private(set) var currentQuestionIndex: Int = 0
    @Published private(set) var startTime: Date = Date()
    @Published private(set) var finishTime: Date?
    @Published private(set) var timerTick: Int = 0
    
    private let maxTime: TimeInterval = 60 * 60 // 60 minutes
    private var timer: Timer?
    
    // MARK: - Computed Properties
    
    var correctCount: Int {
        answers.filter { $0.isCorrect }.count
    }
    
    var isPassed: Bool {
        correctCount >= 17
    }
    
    var remainingTime: TimeInterval {
        if let finishTime = finishTime {
            // Test is finished, return static remaining time
            return max(0, maxTime - finishTime.timeIntervalSince(startTime))
        }
        return max(0, maxTime - Date().timeIntervalSince(startTime))
    }
    
    var timeUsed: TimeInterval {
        if let finishTime = finishTime {
            // Test is finished, return static time used
            return finishTime.timeIntervalSince(startTime)
        }
        // Test is still running, return current time used
        return Date().timeIntervalSince(startTime)
    }
    
    var isFinished: Bool {
        answers.count == questions.count || remainingTime <= 0
    }
    
    var allQuestionsAnswered: Bool {
        answers.count == questions.count
    }
    
    var currentQuestion: TestQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var progress: Double {
        guard questions.count > 0 else { return 0 }
        return Double(answers.count) / Double(questions.count)
    }
    
    // MARK: - Initialization
    
    func initializeTest(generalQuestions: [TestQuestion], regionalQuestions: [TestQuestion]) {
        var finalQuestions: [TestQuestion]
        
        if regionalQuestions.isEmpty {
            // If no regional questions, use 33 federal ones
            finalQuestions = Array(generalQuestions.shuffled().prefix(33))
        } else {
            // Select random 30 general and 3 regional questions
            let general = Array(generalQuestions.shuffled().prefix(30))
            let regional = Array(regionalQuestions.shuffled().prefix(3))
            finalQuestions = (general + regional).shuffled()
        }
        
        self.questions = finalQuestions
        self.startTime = Date()
        self.finishTime = nil
        self.currentQuestionIndex = 0
        self.answers = []
        startTimer()
    }
    
    // MARK: - Answer Management
    
    func answerQuestion(selectedIndex: Int) {
        guard let question = currentQuestion else { return }
        
        let isCorrect = selectedIndex == question.correctIndex
        let answer = TestUserAnswer(
            questionId: question.id,
            selectedIndex: selectedIndex,
            isCorrect: isCorrect,
            answeredAt: Date()
        )
        
        // Remove previous answer for this question (if any)
        answers.removeAll(where: { $0.questionId == question.id })
        answers.append(answer)
    }
    
    func getAnswerForCurrentQuestion() -> TestUserAnswer? {
        guard let question = currentQuestion else { return nil }
        return answers.first(where: { $0.questionId == question.id })
    }
    
    // MARK: - Navigation
    
    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        }
    }
    
    func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }
    
    func goToQuestion(_ index: Int) {
        if index >= 0 && index < questions.count {
            currentQuestionIndex = index
        }
    }
    
    // MARK: - Timer Management
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor [self] in
                self.timerTick += 1
                if self.remainingTime <= 0 {
                    self.timer?.invalidate()
                }
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func finishTest() {
        finishTime = Date()
        stopTimer()
        saveTestResultsToStatistics()
    }
    
    // MARK: - Statistics Integration
    
    /// Saves test session answers to spaced repetition statistics
    private func saveTestResultsToStatistics() {
        let spacedRepetitionManager = SpacedRepetitionManager.shared
        
        // Create a mapping from question ID to original ID
        let questionIdMap: [Int: String] = Dictionary(uniqueKeysWithValues: questions.map { ($0.id, $0.originalId) })
        
        // Record each answer to statistics
        for answer in answers {
            guard let originalId = questionIdMap[answer.questionId] else { continue }
            spacedRepetitionManager.recordAnswer(for: originalId, isCorrect: answer.isCorrect)
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}

