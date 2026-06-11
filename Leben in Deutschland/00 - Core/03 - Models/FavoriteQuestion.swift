//
//  FavoriteQuestion.swift
//  Leben in Deutschland
//
//  One favorited question per federal state. CloudKit-backed.
//  Created: 09.06.26.
//

import Foundation
import SwiftData

@Model
final class FavoriteQuestion {
  var recordId: String = ""
  var federalState: String = ""
  var questionId: String = ""
  var addedAt: Date = Date()

  init(federalState: String, questionId: String, addedAt: Date = Date()) {
    self.recordId = ProgressRecordID.make(federalState: federalState, questionId: questionId)
    self.federalState = federalState
    self.questionId = questionId
    self.addedAt = addedAt
  }

  @MainActor
  static func deleteAll(in context: ModelContext) throws {
    let descriptor = FetchDescriptor<FavoriteQuestion>()
    let all = try context.fetch(descriptor)
    for item in all {
      context.delete(item)
    }
    if context.hasChanges {
      try context.save()
    }
  }
}
