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
    /// Elapsed time shown on results (e.g. 2:36) — realistic for screenshots.
    private static let previewTimeUsedSeconds: TimeInterval = 2 * 60 + 36

    /// 30 federal questions with uneven category mix (English keys → localized in UI).
    /// Excludes regional bucket; those are separate below.
    private static let federalCategoryDistribution: [String] = {
        let chunks: [(String, Int)] = [
            ("Law and Constitution", 4),
            ("History", 4),
            ("State", 3),
            ("Elections", 3),
            ("Family and Education", 3),
            ("State Institutions", 4),
            ("Economy and Work", 3),
            ("Society and Culture", 3),
            ("Europe", 3)
        ]
        var out: [String] = []
        out.reserveCapacity(30)
        for (name, count) in chunks {
            out.append(contentsOf: repeatElement(name, count: count))
        }
        assert(out.count == 30)
        return out
    }()

    /// Creates a TestSessionViewModel with mock answers for previewing pass or fail result screen.
    static func makeMockResultsViewModel(passed: Bool) -> TestSessionViewModel {
        let generalQuestions: [TestQuestion] = federalCategoryDistribution.enumerated().map { i, category in
            TestQuestion(
                id: i,
                originalId: "debug_gen_\(i)",
                text: "Sample federal question \(i + 1) text?",
                options: ["Option A", "Option B", "Option C", "Option D"],
                correctIndex: 0,
                isRegional: false,
                category: category
            )
        }

        // Real exam mix: 30 federal + 3 state (category localizes, e.g. DE → Bundesländer).
        let regionalQuestions: [TestQuestion] = (0..<3).map { i in
            TestQuestion(
                id: 100 + i,
                originalId: "debug_reg_\(i)",
                text: "Sample state (Bundesland) question \(i + 1) text?",
                options: ["Option A", "Option B", "Option C", "Option D"],
                correctIndex: 0,
                isRegional: true,
                category: "Federal States"
            )
        }

        let vm = TestSessionViewModel()
        vm.initializeTest(generalQuestions: generalQuestions, regionalQuestions: regionalQuestions)
        for i in 0..<vm.questions.count {
            vm.goToQuestion(i)
            let q = vm.questions[i]
            let chosen: Int
            if passed {
                chosen = q.correctIndex
            } else {
                // Mostly wrong but keep pass/fail rule: < 17 correct
                chosen = (i % 4 == 0) ? q.correctIndex : (q.correctIndex + 1) % max(1, q.options.count)
            }
            vm.answerQuestion(selectedIndex: chosen)
        }
        vm.finishTest()
        vm.debug_setTimeUsedForPreview(seconds: previewTimeUsedSeconds)
        return vm
    }
}
#endif
