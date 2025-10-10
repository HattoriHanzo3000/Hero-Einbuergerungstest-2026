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
    
    @StateObject private var viewModel: FederalStatesViewModel
    
    // MARK: - Initialization
    init() {
        // Initialize ViewModel - dependencies passed via method parameters
        _viewModel = StateObject(wrappedValue: FederalStatesViewModel())
    }
    
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
                selectedState: stateManager.selectedState,
                onStateSelected: { state in
                    viewModel.handleStateSelection(state, stateManager: stateManager) {
                        dismiss()
                    }
                }
            )
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
    }
}

// MARK: - Preview
#Preview {
    FederalStatesView()
        .environmentObject(StateManager())
}
