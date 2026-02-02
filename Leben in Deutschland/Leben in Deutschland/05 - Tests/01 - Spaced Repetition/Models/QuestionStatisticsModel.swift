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
}

