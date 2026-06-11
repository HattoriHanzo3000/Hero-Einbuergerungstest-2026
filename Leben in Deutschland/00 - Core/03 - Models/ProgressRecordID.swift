//
//  ProgressRecordID.swift
//  Leben in Deutschland
//
//  Composite stable IDs for state-scoped progress rows synced via CloudKit.
//  Created: 09.06.26.
//

import Foundation

enum ProgressRecordID {
  /// Unique key for per-question progress scoped by federal state.
  static func make(federalState: String, questionId: String) -> String {
    "\(federalState)_\(questionId)"
  }
}
