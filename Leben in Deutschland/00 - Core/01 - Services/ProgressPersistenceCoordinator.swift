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
}

// MARK: - Coordinator

@MainActor
final class ProgressPersistenceCoordinator: ProgressPersistenceCoordinating {
  static let shared = ProgressPersistenceCoordinator()

  private(set) var activeFederalState: String

  private var modelContext: ModelContext?
  private var didAttach = false
  private var saveObserver: NSObjectProtocol?
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
    // Phase 3: bind SpacedRepetitionManager, AnswersService, FavoritesManager
  }

  func reloadForFederalState(_ state: String) {
    activeFederalState = state
    persistActiveFederalState(state)
    reloadBoundServices()
  }

  func stopObservingRemoteChanges() {
    if let saveObserver {
      NotificationCenter.default.removeObserver(saveObserver)
      self.saveObserver = nil
    }
    remoteReloadTask?.cancel()
    remoteReloadTask = nil
  }

  // MARK: - Private

  private func bootstrapActiveFederalState(using context: ModelContext) {
    let profile = UserProgressProfile.fetchOrInsertSingleton(in: context)
    let resolved = resolveFederalState(from: profile)
    activeFederalState = resolved

    if profile.activeFederalState != resolved {
      profile.activeFederalState = resolved
      profile.lastUpdated = Date()
      try? context.save()
    }
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
    saveObserver = NotificationCenter.default.addObserver(
      forName: .NSManagedObjectContextDidSave,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      guard let self else { return }
      self.scheduleRemoteReload()
    }
  }

  private func scheduleRemoteReload() {
    remoteReloadTask?.cancel()
    remoteReloadTask = Task { @MainActor in
      try? await Task.sleep(for: .milliseconds(200))
      guard !Task.isCancelled else { return }
      reloadBoundServices()
    }
  }

  private func reloadBoundServices() {
    // Phase 3: SpacedRepetitionManager.shared.reloadForFederalState(activeFederalState)
    // Phase 3: AnswersService.shared.reloadForFederalState(activeFederalState)
    // Phase 3: FavoritesManager.shared.reloadForFederalState(activeFederalState)
  }
}
