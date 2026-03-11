//
//  AppRouter.swift
//  Leben in Deutschland
//
//  Central navigation coordinator using modern NavigationStack pattern
//

import SwiftUI

// MARK: - App Router
@Observable
final class AppRouter {
    var navigationPath = NavigationPath()
    
    // MARK: - Navigation Destinations
    enum Destination: Hashable {
        case allQuestions
        case categories
        case learning(subcategoryName: String, categoryName: String)
        case favorites
        case spacedRepetition
        case testCountdown
        case testSimulation
    }
    
    // MARK: - Navigation Methods
    
    /// Push a new destination onto the navigation stack
    func push(_ destination: Destination) {
        navigationPath.append(destination)
    }
    
    /// Pop the last destination from the stack
    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }
    
    /// Pop to the root view (clear entire stack)
    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    /// Replace the current destination with a new one
    func replace(with destination: Destination) {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
        navigationPath.append(destination)
    }
}

