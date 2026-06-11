//
//  QuestionStatisticsRecord.swift
//  Leben in Deutschland
//
//  SwiftData spaced-repetition stats per question and federal state. CloudKit-backed.
//  Created: 09.06.26.
//

import Foundation
import SwiftData

@Model
final class QuestionStatisticsRecord {
  @Attribute(.unique) var recordId: String = ""
  var federalState: String = ""
  var questionId: String = ""
  var showCount: Int = 0
  var correctCount: Int = 0
  var incorrectCount: Int = 0
  var lastShownDate: Date?
  var nextReviewDate: Date?
  var interval: Int = 1
  var masteryLevel: Int = 0
  var consecutiveCorrect: Int = 0
  var lastAnswerWasCorrect: Bool?

  init(
    federalState: String,
    questionId: String,
    showCount: Int = 0,
    correctCount: Int = 0,
    incorrectCount: Int = 0,
    lastShownDate: Date? = nil,
    nextReviewDate: Date? = nil,
    interval: Int = 1,
    masteryLevel: Int = 0,
    consecutiveCorrect: Int = 0,
    lastAnswerWasCorrect: Bool? = nil
  ) {
    self.recordId = ProgressRecordID.make(federalState: federalState, questionId: questionId)
    self.federalState = federalState
    self.questionId = questionId
    self.showCount = showCount
    self.correctCount = correctCount
    self.incorrectCount = incorrectCount
    self.lastShownDate = lastShownDate
    self.nextReviewDate = nextReviewDate
    self.interval = interval
    self.masteryLevel = masteryLevel
    self.consecutiveCorrect = consecutiveCorrect
    self.lastAnswerWasCorrect = lastAnswerWasCorrect
  }

  func apply(from model: QuestionStatisticsModel) {
    showCount = model.showCount
    correctCount = model.correctCount
    incorrectCount = model.incorrectCount
    lastShownDate = model.lastShownDate
    nextReviewDate = model.nextReviewDate
    interval = model.interval
    masteryLevel = model.masteryLevel
    consecutiveCorrect = model.consecutiveCorrect
    lastAnswerWasCorrect = model.lastAnswerWasCorrect
  }

  @MainActor
  static func deleteAll(in context: ModelContext) throws {
    let descriptor = FetchDescriptor<QuestionStatisticsRecord>()
    let all = try context.fetch(descriptor)
    for item in all {
      context.delete(item)
    }
    if context.hasChanges {
      try context.save()
    }
  }
}
