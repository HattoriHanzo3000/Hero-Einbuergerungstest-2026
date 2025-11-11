//
//  LearnOptionsViewModel.swift
//  Leben in Deutschland
//
//  Provides the curated list of learning pathways for the Learn carousel.
//

import SwiftUI
import Combine

/// Source of truth for the Learn carousel that keeps the options modular and test-friendly.
final class LearnOptionsViewModel: ObservableObject {
    /// Published options backing the horizontal carousel.
    @Published private(set) var options: [LearnOptionModel] = []
    
    /// Closure that forwards the selected option to the parent coordinator or router.
    private var selectionHandler: ((LearnOptionModel) -> Void)?
    
    init(selectionHandler: ((LearnOptionModel) -> Void)? = nil) {
        self.selectionHandler = selectionHandler
        configureOptions()
    }
    
    /// Allows late binding of the selection handler (useful for previews and dependency injection).
    func setSelectionHandler(_ handler: @escaping (LearnOptionModel) -> Void) {
        selectionHandler = handler
    }
    
    /// Handles user intent when tapping an option card.
    func select(_ option: LearnOptionModel) {
        selectionHandler?(option)
    }
}

// MARK: - Private Helpers
private extension LearnOptionsViewModel {
    /// Static setup for the four core learning pathways.
    func configureOptions() {
        options = [
            LearnOptionModel(
                titleKey: "learn_option_spaced_repetition_title",
                descriptionKey: "learn_option_spaced_repetition_description",
                iconSystemName: "arrow.triangle.2.circlepath",
                palette: LearnOptionPalette(
                    gradientColors: [
                        Color("AppBlueLagoon"),
                        Color(red: 0.08, green: 0.24, blue: 0.54)
                    ],
                    accentColor: Color("AppBlueLagoon")
                )
            ),
            LearnOptionModel(
                titleKey: "learn_option_topics_title",
                descriptionKey: "learn_option_topics_description",
                iconSystemName: "square.grid.2x2",
                palette: LearnOptionPalette(
                    gradientColors: [
                        Color("AppCaribean"),
                        Color(red: 0.05, green: 0.38, blue: 0.47)
                    ],
                    accentColor: Color("AppCaribean")
                )
            ),
            LearnOptionModel(
                titleKey: "learn_option_test_title",
                descriptionKey: "learn_option_test_description",
                iconSystemName: "checkmark.seal",
                palette: LearnOptionPalette(
                    gradientColors: [
                        Color("AppOrange"),
                        Color(red: 0.77, green: 0.21, blue: 0.12)
                    ],
                    accentColor: Color("AppOrange")
                )
            ),
            LearnOptionModel(
                titleKey: "learn_option_favorites_title",
                descriptionKey: "learn_option_favorites_description",
                iconSystemName: "heart.fill",
                palette: LearnOptionPalette(
                    gradientColors: [
                        Color("AppPink"),
                        Color(red: 0.53, green: 0.08, blue: 0.30)
                    ],
                    accentColor: Color("AppPink")
                )
            )
        ]
    }
}


