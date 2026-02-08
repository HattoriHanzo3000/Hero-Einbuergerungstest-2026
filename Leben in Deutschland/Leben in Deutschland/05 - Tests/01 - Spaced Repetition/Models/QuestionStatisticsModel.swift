import Foundation

// MARK: - Question Statistics Model
/// Persists spaced repetition metadata for a single question.
struct QuestionStatisticsModel: Codable, Hashable {
    let questionId: String
    var showCount: Int = 0
    var correctCount: Int = 0
    var incorrectCount: Int = 0
    var lastShownDate: Date?
    var nextReviewDate: Date?
    var interval: Int = 1
    var masteryLevel: Int = 0
    var consecutiveCorrect: Int = 0
    /// Tracks the last answer type to enable "undo last input" on reset
    var lastAnswerWasCorrect: Bool? = nil
    
    var accuracy: Double {
        guard showCount > 0 else { return 0 }
        return Double(correctCount) / Double(showCount)
    }
    
    var isMastered: Bool {
        masteryLevel >= 3
    }
    
    mutating func registerAnswer(isCorrect: Bool) {
        showCount += 1
        lastShownDate = Date()
        // Store the last answer type for reset functionality
        lastAnswerWasCorrect = isCorrect
        
        if isCorrect {
            correctCount += 1
            consecutiveCorrect += 1
            incorrectCount = max(incorrectCount - 1, 0)
            if consecutiveCorrect >= 3 {
                interval = min(interval * 2, 30)
                masteryLevel = min(masteryLevel + 1, 3)
                consecutiveCorrect = 0
                nextReviewDate = Calendar.current.date(byAdding: .day, value: interval, to: Date())
            } else {
                interval = min(interval + 1, 30)
                nextReviewDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())
            }
        } else {
            incorrectCount += 1
            consecutiveCorrect = 0
            interval = max(interval / 2, 1)
            masteryLevel = max(masteryLevel - 1, 0)
            nextReviewDate = Calendar.current.date(byAdding: .minute, value: 2, to: Date())
        }
    }

    /// Applies a "reset" by undoing the last input: subtracts from the count that was last incremented.
    /// If last answer was correct → undo that correct (correctCount -1).
    /// If last answer was wrong → undo that wrong (incorrectCount -1).
    /// Does NOT add +1 to the other category - only undoes the last action.
    mutating func applyReset() {
        guard let lastWasCorrect = lastAnswerWasCorrect else {
            // No previous answer to undo - do nothing
            return
        }
        
        if lastWasCorrect {
            // Last input was correct → undo that correct
            correctCount = max(0, correctCount - 1)
            // Adjust consecutiveCorrect if needed
            if consecutiveCorrect > 0 {
                consecutiveCorrect = max(0, consecutiveCorrect - 1)
            }
            // Adjust masteryLevel if needed
            masteryLevel = max(0, masteryLevel - 1)
        } else {
            // Last input was wrong → undo that wrong
            incorrectCount = max(0, incorrectCount - 1)
        }
        
        // Clear the last answer tracking (reset has been applied)
        lastAnswerWasCorrect = nil
        consecutiveCorrect = 0
        nextReviewDate = Calendar.current.date(byAdding: .minute, value: 2, to: Date())
    }
}

