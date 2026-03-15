//
//  DebugTestResultsHelper.swift
//  Leben in Deutschland
//
//  Creates mock TestSessionViewModel for debug preview of pass/fail screens.
//  Only compiled in DEBUG builds.
//

#if DEBUG
import Foundation
import SwiftUI

enum DebugTestResultsHelper {
    private static let categoryNames = [
        "Law and Constitution",
        "History",
        "Federal States",
        "Elections",
        "Family and Education"
    ]

    /// Creates a TestSessionViewModel with mock answers for previewing pass or fail result screen.
    static func makeMockResultsViewModel(passed: Bool) -> TestSessionViewModel {
        let sampleQuestions: [TestQuestion] = (0..<33).map { i in
            TestQuestion(
                id: i,
                originalId: "\(100 + i)",
                text: "Sample question \(i + 1) text?",
                options: ["Option A", "Option B", "Option C", "Option D"],
                correctIndex: 0,
                isRegional: false,
                category: categoryNames[i % categoryNames.count]
            )
        }
        let vm = TestSessionViewModel()
        vm.initializeTest(generalQuestions: sampleQuestions, regionalQuestions: [])
        for i in 0..<vm.questions.count {
            vm.goToQuestion(i)
            let q = vm.questions[i]
            let chosen: Int
            if passed {
                chosen = q.correctIndex
            } else {
                let catIndex = i % categoryNames.count
                chosen = (catIndex % 3 == 0) ? q.correctIndex : (q.correctIndex + 1) % max(1, q.options.count)
            }
            vm.answerQuestion(selectedIndex: chosen)
        }
        vm.finishTest()
        return vm
    }
}
#endif
