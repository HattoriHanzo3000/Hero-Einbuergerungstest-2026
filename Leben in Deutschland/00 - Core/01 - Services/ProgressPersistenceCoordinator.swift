//
//  ProgressPersistenceCoordinator.swift
//  Leben in Deutschland
//
//  Wires SwiftData + CloudKit to progress services; observes remote sync saves.
//  Created: 09.06.26.
//

import CoreData
import Foundation
import SwiftData

// MARK: - Progress Persistence Coordinating

@MainActor
protocol ProgressPersistenceCoordinating: AnyObject {
  var activeFederalState: String { get }
  func attach(modelContext: ModelContext)
  func reloadForFederalState(_ state: String)
  func clearAllProgressData(using defaults: UserDefaults)
}

// MARK: - Coordinator

@MainActor
final class ProgressPersistenceCoordinator: ProgressPersistenceCoordinating {
  static let shared = ProgressPersistenceCoordinator()

  private(set) var activeFederalState: String

  private var modelContext: ModelContext?
  private var didAttach = false
  private var remoteChangeObserver: NSObjectProtocol?
  private var remoteReloadTask: Task<Void, Never>?

  private init() {
    activeFederalState = FederalStateModel.allStates.first?.name ?? "Berlin"
  }

  // MARK: - Attach

  func attach(modelContext: ModelContext) {
    guard !didAttach else { return }
    didAttach = true
    self.modelContext = modelContext
    MigrationManager.migrateLegacyUserDefaultsProgressToSwiftDataIfNeeded(context: modelContext)
    bootstrapActiveFederalState(using: modelContext)
    startObservingRemoteChanges()
    bindProgressServices()
  }

  func reloadForFederalState(_ state: String) {
    applyActiveFederalState(state, reloadServices: true)
  }

  /// Deletes all progress across every federal state (Settings global reset only).
  func clearAllProgressData(using defaults: UserDefaults = .standard) {
    if let context = modelContext {
      try? QuestionStatisticsRecord.deleteAll(in: context)
      try? LearningAnswerRecord.deleteAll(in: context)
      try? FavoriteQuestion.deleteAll(in: context)
      try? UserProgressProfile.deleteAll(in: context)
    }
    MigrationManager.resetProgressMigrationFlags(using: defaults)
    let defaultState = FederalStateModel.allStates.first?.name ?? "Berlin"
    if modelContext != nil {
      applyActiveFederalState(defaultState, reloadServices: true)
    } else {
      applyActiveFederalState(defaultState, reloadServices: false)
      SpacedRepetitionManager.shared.clearAllStatistics()
      AnswersService.shared.clearAllAnswers()
      FavoritesManager.shared.clearAllFavorites()
    }
  }

  func stopObservingRemoteChanges() {
    if let remoteChangeObserver {
      NotificationCenter.default.removeObserver(remoteChangeObserver)
      self.remoteChangeObserver = nil
    }
    remoteReloadTask?.cancel()
    remoteReloadTask = nil
  }

  // MARK: - Private

  private func bootstrapActiveFederalState(using context: ModelContext) {
    let profile = UserProgressProfile.fetchOrInsertSingleton(in: context)
    let resolved = resolveFederalState(from: profile)
    applyActiveFederalState(resolved, reloadServices: false)
  }

  /// Keeps SwiftData, UI selection, and in-memory progress services on the same federal state.
  private func applyActiveFederalState(_ state: String, reloadServices: Bool) {
    activeFederalState = state
    persistActiveFederalState(state)
    syncFederalStateToUI(state)
    if reloadServices, modelContext != nil {
      reloadBoundServices()
    }
  }

  private func syncFederalStateToUI(_ state: String) {
    StateManager.shared.setSelectedState(state)
    OnboardingPreferences.shared.selectedState = state
  }

  private func resolveFederalState(from profile: UserProgressProfile) -> String {
    if !profile.activeFederalState.isEmpty {
      return profile.activeFederalState
    }
    return OnboardingPreferences.shared.selectedState
      ?? StateManager.shared.selectedState
      ?? FederalStateModel.allStates.first?.name
      ?? "Berlin"
  }

  private func persistActiveFederalState(_ state: String) {
    guard let context = modelContext else { return }
    let profile = UserProgressProfile.fetchOrInsertSingleton(in: context)
    profile.activeFederalState = state
    profile.lastUpdated = Date()
    try? context.save()
  }

  private func startObservingRemoteChanges() {
    stopObservingRemoteChanges()
    // CloudKit imports only — local practice saves do not post this notification.
    remoteChangeObserver = NotificationCenter.default.addObserver(
      forName: .NSPersistentStoreRemoteChange,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      MainActor.assumeIsolated {
        self?.scheduleRemoteReload()
      }
    }
  }

  private func scheduleRemoteReload() {
    remoteReloadTask?.cancel()
    remoteReloadTask = Task { @MainActor in
      try? await Task.sleep(for: .milliseconds(200))
      guard !Task.isCancelled else { return }
      guard let context = modelContext else { return }

      let profile = UserProgressProfile.fetchOrInsertSingleton(in: context)
      let syncedState = profile.activeFederalState
      if !syncedState.isEmpty, syncedState != activeFederalState {
        applyActiveFederalState(syncedState, reloadServices: true)
      } else {
        reloadBoundServices()
      }
    }
  }

  private func bindProgressServices() {
    guard let modelContext else { return }
    SpacedRepetitionManager.shared.bind(
      modelContext: modelContext,
      activeFederalState: activeFederalState
    )
    AnswersService.shared.bind(
      modelContext: modelContext,
      activeFederalState: activeFederalState
    )
    FavoritesManager.shared.bind(
      modelContext: modelContext,
      activeFederalState: activeFederalState
    )
  }

  private func reloadBoundServices() {
    SpacedRepetitionManager.shared.reloadForFederalState(activeFederalState)
    AnswersService.shared.reloadForFederalState(activeFederalState)
    FavoritesManager.shared.reloadForFederalState(activeFederalState)
  }
}
