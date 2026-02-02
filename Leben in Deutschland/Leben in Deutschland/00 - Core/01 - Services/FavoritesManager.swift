import Foundation
import Combine

// MARK: - Favorites Managing
protocol FavoritesManaging: AnyObject {
    func isFavorite(_ questionId: String) -> Bool
    func toggleFavorite(for questionId: String)
}

// MARK: - Favorites Manager
final class FavoritesManager: ObservableObject, FavoritesManaging {
    static let shared = FavoritesManager()
    
    @Published private(set) var favoriteQuestionIds: Set<String> = []
    
    private let favoritesKey = "favoriteQuestionIds"
    private let defaults: UserDefaults
    
    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        loadFavorites()
    }
    
    // MARK: - Public API
    func isFavorite(_ questionId: String) -> Bool {
        favoriteQuestionIds.contains(questionId)
    }
    
    func toggleFavorite(for questionId: String) {
        if favoriteQuestionIds.contains(questionId) {
            favoriteQuestionIds.remove(questionId)
        } else {
            favoriteQuestionIds.insert(questionId)
        }
        saveFavorites()
    }
}

// MARK: - Persistence
private extension FavoritesManager {
    func loadFavorites() {
        guard let data = defaults.array(forKey: favoritesKey) as? [String] else {
            favoriteQuestionIds = []
            return
        }
        favoriteQuestionIds = Set(data)
    }
    
    func saveFavorites() {
        defaults.set(Array(favoriteQuestionIds), forKey: favoritesKey)
    }
}

