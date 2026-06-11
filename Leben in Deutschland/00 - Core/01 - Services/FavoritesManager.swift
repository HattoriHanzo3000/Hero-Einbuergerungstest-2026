import Foundation
import Combine
import SwiftData

// MARK: - Favorites Managing
protocol FavoritesManaging: AnyObject {
    func isFavorite(_ questionId: String) -> Bool
    @discardableResult
    func toggleFavorite(for questionId: String, isPro: Bool) -> Bool
}

// MARK: - Favorites Manager
/// Stores favorite question IDs in add order (oldest first in array). Use reversed order for UI (newest first).
@MainActor
final class FavoritesManager: ObservableObject, FavoritesManaging {
    static let shared = FavoritesManager()

    /// Ordered list: oldest first, newest last. For “newest first” display, use reversed.
    @Published private(set) var favoriteQuestionIds: [String] = []

    private let defaults: UserDefaults
    private var modelContext: ModelContext?
    private var activeFederalState: String = ""

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func bind(modelContext: ModelContext, activeFederalState: String) {
        self.modelContext = modelContext
        self.activeFederalState = activeFederalState
        reloadFromStore()
    }

    func reloadForFederalState(_ state: String) {
        activeFederalState = state
        reloadFromStore()
    }

    // MARK: - Public API
    func isFavorite(_ questionId: String) -> Bool {
        favoriteQuestionIds.contains(questionId)
    }

    @discardableResult
    func toggleFavorite(for questionId: String, isPro: Bool) -> Bool {
        if let index = favoriteQuestionIds.firstIndex(of: questionId) {
            favoriteQuestionIds.remove(at: index)
            persist()
            return true
        }
        if !isPro && favoriteQuestionIds.count >= FreemiumLimits.freeFavoritesMax {
            return false
        }
        favoriteQuestionIds.append(questionId)
        persist()
        return true
    }

    /// Reloads favorites from persistence (e.g. after app reset). Replaces in-memory state with stored state.
    func reloadFromStorage() {
        reloadFromStore()
    }

    func clearAllFavorites() {
        favoriteQuestionIds.removeAll()
        defaults.removeObject(forKey: UserDefaultsKeys.favoriteQuestionIds)
        guard let context = modelContext else { return }
        try? FavoriteQuestion.deleteAll(in: context)
    }
}

// MARK: - Persistence
private extension FavoritesManager {
    func reloadFromStore() {
        guard let context = modelContext, !activeFederalState.isEmpty else {
            favoriteQuestionIds = []
            return
        }

        let state = activeFederalState
        let descriptor = FetchDescriptor<FavoriteQuestion>(
            predicate: #Predicate<FavoriteQuestion> { $0.federalState == state },
            sortBy: [SortDescriptor(\.addedAt)]
        )
        let rows = (try? context.fetch(descriptor)) ?? []
        favoriteQuestionIds = rows.map(\.questionId)
    }

    func persist() {
        guard let context = modelContext, !activeFederalState.isEmpty else { return }

        let state = activeFederalState
        let descriptor = FetchDescriptor<FavoriteQuestion>(
            predicate: #Predicate<FavoriteQuestion> { $0.federalState == state }
        )
        let existing = (try? context.fetch(descriptor)) ?? []
        let existingIds = Set(existing.map(\.questionId))
        let desiredIds = favoriteQuestionIds

        for row in existing where !desiredIds.contains(row.questionId) {
            context.delete(row)
        }

        for questionId in desiredIds where !existingIds.contains(questionId) {
            context.insert(FavoriteQuestion(federalState: activeFederalState, questionId: questionId))
        }
        try? context.save()
    }
}
