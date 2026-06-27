//
//  FeedbackReportView.swift
//  Leben in Deutschland
//
//  In-app feedback form for reporting questions.
//  Sends reports to the CloudKit public database.
//

import SwiftUI

struct FeedbackReportView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var languageManager: LanguageManager
    
    let questionId: String?
    let questionText: String?
    let category: String?
    
    @StateObject private var feedbackService = FeedbackService.shared
    @FocusState private var focusedField: FocusField?
    @State private var selectedType: FeedbackModel.FeedbackType = .questionError
    @State private var message: String = ""
    @State private var userEmail: String = ""
    @State private var showingSuccess = false
    @State private var showingError = false
    @State private var errorMessage: String = ""
    
    private enum FocusField: Hashable {
        case message
        case email
    }
    
    private var canSubmit: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !feedbackService.isSubmitting
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if let questionId = questionId {
                        LabeledContent("question_id".localized, value: questionId)
                    }
                } header: {
                    Text("question_info".localized)
                }
                
                Section {
                    Picker("feedback_type".localized, selection: $selectedType) {
                        ForEach(FeedbackModel.FeedbackType.allCases, id: \.self) { type in
                            Text(type.localizedTitle).tag(type)
                        }
                    }
                } header: {
                    Text("what_would_you_like_to_report".localized)
                }
                
                Section {
                    TextEditor(text: $message)
                        .frame(minHeight: 120)
                        .focused($focusedField, equals: .message)
                } header: {
                    Text("additional_details".localized)
                } footer: {
                    Text("feedback_details_hint".localized)
                        .font(.caption)
                }
                
                Section {
                    TextField("email_optional".localized, text: $userEmail)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .email)
                } header: {
                    Text("contact_info".localized)
                } footer: {
                    Text("feedback_email_hint".localized)
                        .font(.caption)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: selectedType) { _, _ in
                focusedField = nil
            }
            .navigationTitle("report_question".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        HapticManager.shared.lightImpact()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("close".localized)
                }
                ToolbarItem(placement: .confirmationAction) {
                    sendToolbarButton
                }
            }
            .alert("feedback_submitted".localized, isPresented: $showingSuccess) {
                Button("ok".localized) {
                    dismiss()
                }
            } message: {
                Text("feedback_submitted_message".localized)
            }
            .alert("error".localized, isPresented: $showingError) {
                Button("ok".localized) { }
            } message: {
                Text(errorMessage)
            }
            .overlay {
                if feedbackService.isSubmitting {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
            }
        }
    }
    
    @ViewBuilder
    private var sendToolbarButton: some View {
        let button = Button {
            HapticManager.shared.lightImpact()
            submitFeedback()
        } label: {
            Image(systemName: "arrow.up")
                .fontWeight(.semibold)
        }
        .buttonBorderShape(.circle)
        .disabled(!canSubmit)
        .accessibilityLabel("submit".localized)
        
        if #available(iOS 26.0, *) {
            button
                .buttonStyle(.glassProminent)
                .controlSize(.regular)
        } else {
            button
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
    }
    
    private func submitFeedback() {
        focusedField = nil
        Task {
            do {
                let feedback = FeedbackModel(
                    questionId: questionId,
                    questionText: questionText,
                    category: category,
                    feedbackType: selectedType,
                    message: message,
                    userEmail: userEmail.isEmpty ? nil : userEmail,
                    deviceInfo: feedbackService.getDeviceInfo(),
                    appVersion: feedbackService.getAppVersion(),
                    timestamp: Date(),
                    language: languageManager.currentAppLanguage
                )
                
                try await feedbackService.submitFeedback(feedback)
                showingSuccess = true
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

