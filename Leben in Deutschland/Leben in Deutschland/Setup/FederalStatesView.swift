//
//  FederalStatesView.swift
//  Leben in Deutschland
//
//  Main coordinator view for federal states selection
//

import SwiftUI

// MARK: - Federal States View
struct FederalStatesView: View {
    @EnvironmentObject var stateManager: StateManager
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = FederalStatesViewModel()
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Header
            SetupHeader(title: "federal_states_title", onDismiss: {
                dismiss()
            })
            
            // State Selection List
            StateSelectionList(
                states: viewModel.states,
                selectedState: viewModel.selectedState,
                onStateSelected: { state in
                    viewModel.handleStateSelection(state, stateManager: stateManager) {
                        dismiss()
                    }
                }
            )
            .padding(.top, MainScreenConstants.adaptiveValue(8))
            .padding(.bottom, MainScreenConstants.adaptiveValue(16))
        }
        .background(Color(.systemBackground))
        .overlay(
            // State Change Confirmation Dialog
            StateChangeConfirmationDialog(
                isPresented: viewModel.showStateChangeWarning,
                onCancel: {
                    viewModel.cancelStateChange()
                },
                onConfirm: {
                    viewModel.confirmStateChange(stateManager: stateManager) {
                        dismiss()
                    }
                }
            )
        )
        .onAppear {
            viewModel.initializeState(from: stateManager)
        }
        .onChange(of: stateManager.selectedState) { _, newValue in
            guard viewModel.selectedState != newValue else { return }
            viewModel.initializeState(from: stateManager)
        }
    }
}

// MARK: - Preview
#Preview {
    FederalStatesView()
        .environmentObject(StateManager())
}

#Preview("Medium") {
    FederalStatesView()
        .environmentObject(StateManager())
        .environment(\.dynamicTypeSize, .medium)
}

#Preview("xxxLarge") {
    FederalStatesView()
        .environmentObject(StateManager())
        .environment(\.dynamicTypeSize, .xxxLarge)
}
