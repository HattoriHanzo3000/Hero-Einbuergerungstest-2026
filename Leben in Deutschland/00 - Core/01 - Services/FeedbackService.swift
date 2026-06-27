//
//  FeedbackService.swift
//  Leben in Deutschland
//
//  Service for handling user feedback and question reporting.
//  Saves reports to the CloudKit public database.
//

import CloudKit
import Combine
import Foundation
import SwiftUI

// MARK: - Feedback Model

struct FeedbackModel: Codable {
    let questionId: String?
    let questionText: String?
    let category: String?
    let feedbackType: FeedbackType
    let message: String
    let userEmail: String?
    let deviceInfo: String
    let appVersion: String
    let timestamp: Date
    let language: String

    enum FeedbackType: String, Codable, CaseIterable {
        case questionError = "question_error"
        case questionUnclear = "question_unclear"
        case answerIncorrect = "answer_incorrect"
        case translationIssue = "translation_issue"
        case other = "other"

        var localizedTitle: String {
            switch self {
            case .questionError:
                return "feedback_type_question_error".localized
            case .questionUnclear:
                return "feedback_type_question_unclear".localized
            case .answerIncorrect:
                return "feedback_type_answer_incorrect".localized
            case .translationIssue:
                return "feedback_type_translation_issue".localized
            case .other:
                return "feedback_type_other".localized
            }
        }
    }
}

// MARK: - Feedback Service

final class FeedbackService: ObservableObject {
    static let shared = FeedbackService()

    @Published var isSubmitting = false
    @Published var lastSubmissionError: String?

    private let container = CKContainer(identifier: QuestionFeedbackCloudKitSchema.containerIdentifier)
    private let rateLimiter = QuestionFeedbackRateLimiter()

    private init() {}

    /// Submit feedback to the CloudKit public database.
    @MainActor
    func submitFeedback(_ feedback: FeedbackModel) async throws {
        isSubmitting = true
        defer { isSubmitting = false }

        try rateLimiter.enforceLimit()
        try await ensureiCloudAvailable()

        let record = feedback.makeQuestionFeedbackRecord()
        do {
            let saved = try await container.publicCloudDatabase.save(record)
            rateLimiter.recordSuccessfulSubmission()
            #if DEBUG
            print("✅ Question feedback saved to CloudKit: \(saved.recordID.recordName)")
            #endif
        } catch let error as CKError {
            throw FeedbackError.from(ckError: error)
        }
    }

    @MainActor
    private func ensureiCloudAvailable() async throws {
        let status = try await container.accountStatus()
        switch status {
        case .available:
            return
        case .noAccount, .restricted, .temporarilyUnavailable:
            throw FeedbackError.iCloudUnavailable
        case .couldNotDetermine:
            throw FeedbackError.serverUnavailable
        @unknown default:
            throw FeedbackError.iCloudUnavailable
        }
    }

    /// Generate device info string
    func getDeviceInfo() -> String {
        let device = UIDevice.current
        return "\(device.model) iOS \(device.systemVersion)"
    }

    /// Get app version string
    func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "\(version) (\(build))"
    }
}

// MARK: - Rate limiting

private struct QuestionFeedbackRateLimiter {
    private static let maxSubmissionsPerHour = 5
    private static let window: TimeInterval = 3600

    func enforceLimit() throws {
        let recent = recentSubmissionTimestamps()
        guard recent.count < Self.maxSubmissionsPerHour else {
            throw FeedbackError.rateLimitExceeded
        }
    }

    func recordSuccessfulSubmission(at date: Date = .now) {
        var recent = recentSubmissionTimestamps(relativeTo: date)
        recent.append(date)
        UserDefaults.standard.set(
            recent.map(\.timeIntervalSince1970),
            forKey: UserDefaultsKeys.questionFeedbackSubmissionTimestamps
        )
    }

    private func recentSubmissionTimestamps(relativeTo now: Date = .now) -> [Date] {
        let cutoff = now.addingTimeInterval(-Self.window)
        let stored = UserDefaults.standard.array(
            forKey: UserDefaultsKeys.questionFeedbackSubmissionTimestamps
        ) as? [TimeInterval] ?? []
        return stored
            .map { Date(timeIntervalSince1970: $0) }
            .filter { $0 > cutoff }
    }
}

// MARK: - CloudKit Mapping

private extension FeedbackModel {
    func makeQuestionFeedbackRecord() -> CKRecord {
        let record = CKRecord(recordType: QuestionFeedbackCloudKitSchema.recordType)
        let field = QuestionFeedbackCloudKitSchema.Field.self

        if let questionId {
            record[field.questionId] = questionId as CKRecordValue
        }
        if let questionText {
            let truncated = String(questionText.prefix(QuestionFeedbackCloudKitSchema.maxQuestionTextLength))
            record[field.questionText] = truncated as CKRecordValue
        }
        if let category {
            record[field.category] = category as CKRecordValue
        }
        record[field.feedbackType] = feedbackType.rawValue as CKRecordValue
        record[field.message] = message as CKRecordValue
        if let userEmail, !userEmail.isEmpty {
            record[field.userEmail] = userEmail as CKRecordValue
        }
        record[field.deviceInfo] = deviceInfo as CKRecordValue
        record[field.appVersion] = appVersion as CKRecordValue
        record[field.language] = language as CKRecordValue
        record[field.submittedAt] = timestamp as CKRecordValue

        return record
    }
}

// MARK: - Feedback Errors

enum FeedbackError: LocalizedError {
    case iCloudUnavailable
    case networkUnavailable
    case quotaExceeded
    case rateLimitExceeded
    case serverUnavailable

    var errorDescription: String? {
        switch self {
        case .iCloudUnavailable:
            return "feedback_error_icloud_unavailable".localized
        case .networkUnavailable:
            return "feedback_error_network".localized
        case .rateLimitExceeded:
            return "feedback_error_rate_limit".localized
        case .quotaExceeded, .serverUnavailable:
            return "feedback_error_server".localized
        }
    }

    static func from(ckError: CKError) -> FeedbackError {
        switch ckError.code {
        case .networkUnavailable, .networkFailure, .zoneBusy:
            return .networkUnavailable
        case .quotaExceeded:
            return .quotaExceeded
        case .notAuthenticated, .permissionFailure:
            return .iCloudUnavailable
        case .serviceUnavailable, .requestRateLimited, .serverResponseLost:
            return .serverUnavailable
        default:
            return .serverUnavailable
        }
    }
}
