import SwiftUI

// MARK: - Main List Model
struct MainListModel: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let accessibilityLabel: String
    let accessibilityHint: String
    let destination: CategoryDestination
    
    enum CategoryDestination {
        case startLearning
        case learnByTopics
        case favorites
        case takeTest
    }
    
    static let allCategories = [
        MainListModel(
            title: "main_category_study",
            icon: "book.fill",
            accessibilityLabel: "Start Learning",
            accessibilityHint: "Begin spaced repetition learning",
            destination: .startLearning
        ),
        MainListModel(
            title: "main_category_all_questions",
            icon: "folder.fill",
            accessibilityLabel: "Learn by Topics",
            accessibilityHint: "Study questions organized by categories",
            destination: .learnByTopics
        ),
        MainListModel(
            title: "main_category_favorites",
            icon: "heart.fill",
            accessibilityLabel: "Favorites",
            accessibilityHint: "View your saved favorite questions",
            destination: .favorites
        ),
        MainListModel(
            title: "main_category_test_simulation",
            icon: "timer",
            accessibilityLabel: "Take a Test",
            accessibilityHint: "Practice with a full test simulation",
            destination: .takeTest
        )
    ]
}
