//
//  TestModels.swift
//  Leben in Deutschland
//
//  Models for test simulation feature
//

import Foundation

// MARK: - Test Question Model
struct TestQuestion: Identifiable, Hashable {
    let id: Int
    let originalId: String // Original question ID from QuestionModel
    let text: String
    let options: [String]
    let correctIndex: Int
    let isRegional: Bool
    let category: String
}

// MARK: - Test User Answer Model
struct TestUserAnswer: Identifiable, Hashable {
    let id = UUID()
    let questionId: Int
    let selectedIndex: Int
    let isCorrect: Bool
    let answeredAt: Date
}

// MARK: - Test Results Model
struct TestResults {
    let correctAnswers: Int
    let totalQuestions: Int
    let isPassed: Bool
    let timeUsed: TimeInterval
    let answers: [TestUserAnswer]
    
    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }
    
    var timeString: String {
        let minutes = Int(timeUsed) / 60
        let seconds = Int(timeUsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

