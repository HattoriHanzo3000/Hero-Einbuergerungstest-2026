//
//  DebugTestSessionPreviewView.swift
//  Leben in Deutschland
//
//  In-progress test simulation for App Store screenshots (DEBUG only).
//  UI uses the app language; question text/options are always German (like test simulation).
//

#if DEBUG
import SwiftUI

struct DebugTestSessionPreviewPresentation: Identifiable {
    let id = UUID()
}

struct DebugTestSessionPreviewView: View {
    let onDismiss: () -> Void

    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var favoritesManager: FavoritesManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.layoutMetrics) private var layoutMetrics

    @State private var viewModel: TestSessionViewModel?
    @State private var showingTimerPopup = true
    @State private var zoomedAsset: ZoomedAsset?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    TestSessionQuestionCard(
                        viewModel: viewModel,
                        showingTimerPopup: $showingTimerPopup,
                        zoomedAsset: $zoomedAsset,
                        onFinish: onDismiss,
                        onDismiss: onDismiss
                    )
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("test_simulation_title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .hidesLearningChrome()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        HapticManager.shared.lightImpact()
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    .tint(.primary)
                    .accessibilityLabel("close".localized)
                    .disabled(viewModel == nil)
                }
            }
        }
        .id(languageManager.currentAppLanguage)
        .environmentObject(languageManager)
        .environmentObject(favoritesManager)
        .environmentObject(subscriptionManager)
        .layoutMetrics(layoutMetrics)
        .task {
            viewModel = await DebugTestSessionHelper.makeScreenshotViewModel()
        }
        .onDisappear {
            viewModel?.stopTimer()
        }
    }
}
#endif
