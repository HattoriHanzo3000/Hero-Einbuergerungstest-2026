//
//  FeedbackService.swift
//  Leben in Deutschland
//
//  Service for handling user feedback and question reporting
//  Sends reports directly to backend API - no mail app needed
//

import Foundation
import SwiftUI
import Combine

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
    
    // TODO: Replace with your actual backend API endpoint
    // For development: Set to nil to use local logging
    // For production: Set to your API endpoint like "https://your-api.com/api/feedback"
    private let apiEndpoint: String? = nil // Set to nil for development logging
    
    private init() {}
    
    /// Submit feedback directly to backend API - no mail app needed
    @MainActor
    func submitFeedback(_ feedback: FeedbackModel) async throws {
        isSubmitting = true
        defer { isSubmitting = false }
        
        // DEVELOPMENT MODE: Log to console and save to file
        if apiEndpoint == nil {
            await logFeedbackLocally(feedback)
            return
        }
        
        // PRODUCTION MODE: Send to API
        guard let url = URL(string: apiEndpoint!) else {
            throw FeedbackError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode feedback as JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        request.httpBody = try encoder.encode(feedback)
        
        // Send request
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FeedbackError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw FeedbackError.serverError(httpResponse.statusCode)
        }
        
        // Success - data received (you can decode response if needed)
        print("✅ Feedback submitted successfully")
    }
    
    /// Log feedback locally for development (console + file)
    @MainActor
    private func logFeedbackLocally(_ feedback: FeedbackModel) async {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let jsonData = try encoder.encode(feedback)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "Failed to encode"
            
            // Print to console with full path
            print("\n📧 FEEDBACK REPORT:")
            print(String(repeating: "=", count: 70))
            print(jsonString)
            print(String(repeating: "=", count: 70))
            
            // Save to file (for easy access)
            let filePath = await saveFeedbackToFile(jsonString, feedback: feedback)
            
            // Print detailed location info
            if let path = filePath {
                print("\n💾 FEEDBACK SAVED SUCCESSFULLY!")
                print("📍 Full Path: \(path)")
                print("\n📱 HOW TO ACCESS:")
                print("   1. On Simulator:")
                print("      • Open Finder")
                print("      • Press Cmd+Shift+G")
                print("      • Paste: \(path)")
                print("   2. On Device:")
                print("      • Open Files app")
                print("      • Go to: On My iPhone → Hero → feedback_*.json")
                print("   3. In Xcode:")
                print("      • Window → Devices and Simulators")
                print("      • Select your device/simulator")
                print("      • Click 'Download Container'")
                print("      • Navigate to AppData/Documents/")
                print("\n")
            }
            
        } catch {
            print("❌ Error encoding feedback: \(error)")
        }
    }
    
    /// Save feedback to a file in app's documents directory
    /// Returns the full file path for easy access
    private func saveFeedbackToFile(_ jsonString: String, feedback: FeedbackModel) async -> String? {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ Could not access Documents directory")
            return nil
        }
        
        let fileName = "feedback_\(feedback.timestamp.timeIntervalSince1970).json"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        do {
            try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL.path
        } catch {
            print("❌ Error saving feedback file: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Generate device info string
    func getDeviceInfo() -> String {
        let device = UIDevice.current
        let systemVersion = device.systemVersion
        let model = device.model
        return "\(model) iOS \(systemVersion)"
    }
    
    /// Get app version string
    func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "\(version) (\(build))"
    }
}

// MARK: - Feedback Errors
enum FeedbackError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(Int)
    case encodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API endpoint"
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .encodingError:
            return "Failed to encode feedback data"
        }
    }
}

