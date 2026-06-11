//
//  LearningAnswerRecord.swift
//  Leben in Deutschland
//
//  Learn-by-topics answer per question and federal state. CloudKit-backed.
//  Created: 09.06.26.
//

import Foundation
import SwiftData

@Model
final class LearningAnswerRecord {
  var recordId: String = ""
  var federalState: String = ""
  var questionId: String = ""
  var answerIndex: Int = 0

  init(federalState: String, questionId: String, answerIndex: Int) {
    self.recordId = ProgressRecordID.make(federalState: federalState, questionId: questionId)
    self.federalState = federalState
    self.questionId = questionId
    self.answerIndex = answerIndex
  }

  @MainActor
  static func deleteAll(in context: ModelContext) throws {
    let descriptor = FetchDescriptor<LearningAnswerRecord>()
    let all = try context.fetch(descriptor)
    for item in all {
      context.delete(item)
    }
    if context.hasChanges {
      try context.save()
    }
  }
}
