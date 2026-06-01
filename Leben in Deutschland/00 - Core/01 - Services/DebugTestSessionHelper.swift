//
//  DebugTestSessionHelper.swift
//  Leben in Deutschland
//
//  Frozen in-progress test simulation for App Store screenshots (DEBUG).
//

#if DEBUG
import Foundation

enum DebugTestSessionHelper {
    /// 1-based position in the test navigation (question 8 of 33).
    static let screenshotCurrentQuestionNumber = 8

    /// Frozen remaining countdown (58:28).
    static let screenshotRemainingTimeSeconds: TimeInterval = 58 * 60 + 28

    /// Official catalog id shown as question 8.
    static let screenshotQuestionOriginalId = "234"

    @MainActor
    static func makeScreenshotViewModel() async -> TestSessionViewModel {
        let questions = await buildScreenshotQuestions()
        let vm = TestSessionViewModel()
        vm.debug_initializeTest(questions: questions)

        let answeredCount = screenshotCurrentQuestionNumber - 1
        for index in 0..<answeredCount {
            let q = questions[index]
            vm.debug_recordAnswer(at: index, selectedIndex: q.correctIndex)
        }

        vm.goToQuestion(screenshotCurrentQuestionNumber - 1)
        vm.debug_setRemainingTimeForPreview(seconds: screenshotRemainingTimeSeconds)
        return vm
    }

    @MainActor
    private static func buildScreenshotQuestions() async -> [TestQuestion] {
        let slotIndex = screenshotCurrentQuestionNumber - 1
        let question234 = await loadQuestion234German()
        return (0..<33).map { index in
            if index == slotIndex {
                question234
            } else {
                placeholderQuestion(number: index + 1)
            }
        }
    }

    @MainActor
    private static func loadQuestion234German() async -> TestQuestion {
        let language = ContentService.testSimulationLanguageCode
        if var loaded = try? await ContentService.shared.federalTestQuestion(
            originalId: screenshotQuestionOriginalId,
            language: language
        ) {
            loaded = TestQuestion(
                id: screenshotCurrentQuestionNumber,
                originalId: loaded.originalId,
                text: loaded.text,
                options: loaded.options,
                correctIndex: loaded.correctIndex,
                isRegional: loaded.isRegional,
                category: loaded.category
            )
            return loaded
        }

        return TestQuestion(
            id: screenshotCurrentQuestionNumber,
            originalId: screenshotQuestionOriginalId,
            text: "Wo ist ein Sitz des Europäischen Parlaments?",
            options: ["London", "Paris", "Berlin", "Straßburg"],
            correctIndex: 3,
            isRegional: false,
            category: "Europa"
        )
    }

    private static func placeholderQuestion(number: Int) -> TestQuestion {
        TestQuestion(
            id: number,
            originalId: "debug_screenshot_\(number)",
            text: "Platzhalter Frage \(number)",
            options: ["Antwort A", "Antwort B", "Antwort C", "Antwort D"],
            correctIndex: 0,
            isRegional: false,
            category: "Bund"
        )
    }
}
#endif
