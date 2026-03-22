import Foundation
import Combine

// MARK: - Favorites Managing
protocol FavoritesManaging: AnyObject {
    func isFavorite(_ questionId: String) -> Bool
    @discardableResult
    func toggleFavorite(for questionId: String, isPremium: Bool) -> Bool
}

// MARK: - Favorites Manager
/// Stores favorite question IDs in add order (oldest first in array). Use reversed order for UI (newest first).
final class FavoritesManager: ObservableObject, FavoritesManaging {
    static let shared = FavoritesManager()
    
    /// Ordered list: oldest first, newest last. For “newest first” display, use reversed.
    @Published private(set) var favoriteQuestionIds: [String] = []

    private let defaults: UserDefaults
    
    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        loadFavorites()
    }
    
    // MARK: - Public API
    func isFavorite(_ questionId: String) -> Bool {
        favoriteQuestionIds.contains(questionId)
    }
    
    @discardableResult
    func toggleFavorite(for questionId: String, isPremium: Bool) -> Bool {
        if let index = favoriteQuestionIds.firstIndex(of: questionId) {
            favoriteQuestionIds.remove(at: index)
            saveFavorites()
            return true
        }
        if !isPremium && favoriteQuestionIds.count >= FreemiumLimits.freeFavoritesMax {
            return false
        }
        favoriteQuestionIds.append(questionId)
        saveFavorites()
        return true
    }

    /// Reloads favorites from persistence (e.g. after app reset). Replaces in-memory state with stored state.
    func reloadFromStorage() {
        loadFavorites()
    }
}

// MARK: - Persistence
private extension FavoritesManager {
    func loadFavorites() {
        guard let data = defaults.array(forKey: UserDefaultsKeys.favoriteQuestionIds) as? [String] else {
            favoriteQuestionIds = []
            return
        }
        favoriteQuestionIds = data
    }
    
    func saveFavorites() {
        defaults.set(favoriteQuestionIds, forKey: UserDefaultsKeys.favoriteQuestionIds)
    }
}

