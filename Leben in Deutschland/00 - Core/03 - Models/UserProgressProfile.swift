//
//  UserProgressProfile.swift
//  Leben in Deutschland
//
//  Singleton profile: active federal state and global test date. CloudKit-backed.
//  Created: 09.06.26.
//

import Foundation
import SwiftData

enum UserProgressProfileKeys {
  static let singletonKey = "default"
}

@Model
final class UserProgressProfile {
  var singletonKey: String = UserProgressProfileKeys.singletonKey
  var activeFederalState: String = ""
  var testDate: Date?
  var testDateDontKnow: Bool = true
  var lastUpdated: Date = Date()

  init(
    singletonKey: String = UserProgressProfileKeys.singletonKey,
    activeFederalState: String = "",
    testDate: Date? = nil,
    testDateDontKnow: Bool = true,
    lastUpdated: Date = Date()
  ) {
    self.singletonKey = singletonKey
    self.activeFederalState = activeFederalState
    self.testDate = testDate
    self.testDateDontKnow = testDateDontKnow
    self.lastUpdated = lastUpdated
  }
}

// MARK: - IO

extension UserProgressProfile {
  @MainActor
  static func fetchExistingSingleton(in context: ModelContext) -> UserProgressProfile? {
    let key = UserProgressProfileKeys.singletonKey
    var descriptor = FetchDescriptor<UserProgressProfile>(
      predicate: #Predicate<UserProgressProfile> { $0.singletonKey == key }
    )
    descriptor.fetchLimit = 1
    return try? context.fetch(descriptor).first
  }

  @MainActor
  static func fetchOrInsertSingleton(in context: ModelContext) -> UserProgressProfile {
    let key = UserProgressProfileKeys.singletonKey
    var descriptor = FetchDescriptor<UserProgressProfile>(
      predicate: #Predicate<UserProgressProfile> { $0.singletonKey == key }
    )
    descriptor.fetchLimit = 1
    if let existing = try? context.fetch(descriptor).first {
      return existing
    }
    let created = UserProgressProfile()
    context.insert(created)
    return created
  }

  @MainActor
  static func deleteAll(in context: ModelContext) throws {
    let descriptor = FetchDescriptor<UserProgressProfile>()
    let all = try context.fetch(descriptor)
    for item in all {
      context.delete(item)
    }
    if context.hasChanges {
      try context.save()
    }
  }
}
