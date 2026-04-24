//
//  FreemiumUsageService.swift
//  Leben in Deutschland
//
//  Tracks freemium usage (Smart Learning questions, test simulations). Pro users bypass all checks.
//

import Foundation

@MainActor
final class FreemiumUsageService {
    static let shared = FreemiumUsageService()

    private let defaults: UserDefaults

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Smart Learning (Spaced Repetition)

    var smartLearningAnswersRecorded: Int {
        defaults.integer(forKey: UserDefaultsKeys.freemiumSmartLearningAnswerCount)
    }

    func canRecordSmartLearningAnswer(isPro: Bool) -> Bool {
        isPro || smartLearningAnswersRecorded < FreemiumLimits.freeSmartLearningQuestions
    }

    func recordSmartLearningAnswer() {
        let current = defaults.integer(forKey: UserDefaultsKeys.freemiumSmartLearningAnswerCount)
        defaults.set(current + 1, forKey: UserDefaultsKeys.freemiumSmartLearningAnswerCount)
    }

    // MARK: - Test Simulation

    var testSimulationsStartedCount: Int {
        defaults.integer(forKey: UserDefaultsKeys.freemiumTestSimulationsStartedCount)
    }

    func canStartTestSimulation(isPro: Bool) -> Bool {
        isPro || testSimulationsStartedCount < FreemiumLimits.freeTestSimulations
    }

    func recordTestSimulationStarted() {
        let current = defaults.integer(forKey: UserDefaultsKeys.freemiumTestSimulationsStartedCount)
        defaults.set(current + 1, forKey: UserDefaultsKeys.freemiumTestSimulationsStartedCount)
    }
}
