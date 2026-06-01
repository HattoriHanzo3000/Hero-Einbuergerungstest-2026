//
//  DebugTestSessionPreviewView.swift
//  Leben in Deutschland
//
//  In-progress test simulation for App Store screenshots (DEBUG only).
//

#if DEBUG
import SwiftUI

struct DebugTestSessionPreviewPresentation: Identifiable {
    let id = UUID()
    let viewModel: TestSessionViewModel
}

struct DebugTestSessionPreviewView: View {
    @ObservedObject var viewModel: TestSessionViewModel
    let onDismiss: () -> Void

    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var favoritesManager: FavoritesManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Environment(\.layoutMetrics) private var layoutMetrics

    @State private var showingTimerPopup = true
    @State private var zoomedAsset: ZoomedAsset?

    var body: some View {
        NavigationStack {
            TestSessionQuestionCard(
                viewModel: viewModel,
                showingTimerPopup: $showingTimerPopup,
                zoomedAsset: $zoomedAsset,
                onFinish: onDismiss,
                onDismiss: onDismiss
            )
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
                }
            }
        }
        .environmentObject(languageManager)
        .environmentObject(favoritesManager)
        .environmentObject(subscriptionManager)
        .layoutMetrics(layoutMetrics)
        .onDisappear {
            viewModel.stopTimer()
        }
    }
}
#endif
