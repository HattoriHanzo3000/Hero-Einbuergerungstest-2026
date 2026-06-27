//
//  QuestionFeedbackCloudKitSchema.swift
//  Leben in Deutschland
//
//  CloudKit public-database contract for question reports.
//  Must match CloudKit/QuestionFeedback.ckdb and the Development schema.
//  Created: 27.06.26.
//

import Foundation

enum QuestionFeedbackCloudKitSchema {
    static let containerIdentifier = "iCloud.com.gizatech.Leben-in-Deutschland"
    static let recordType = "QuestionFeedback"
    static let maxQuestionTextLength = 4_000

    enum Field {
        static let questionId = "questionId"
        static let questionText = "questionText"
        static let category = "category"
        static let feedbackType = "feedbackType"
        static let message = "message"
        static let userEmail = "userEmail"
        static let deviceInfo = "deviceInfo"
        static let appVersion = "appVersion"
        static let language = "language"
        static let submittedAt = "submittedAt"
    }
}
