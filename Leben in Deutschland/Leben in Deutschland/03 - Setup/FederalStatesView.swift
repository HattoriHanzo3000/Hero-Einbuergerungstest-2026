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
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: MainScreenConstants.adaptiveValue(16)) {
                SetupHeader(title: "federal_states_title", onDismiss: {
                    dismiss()
                })
                
                StateSelectionList(
                    states: viewModel.states,
                    selectedState: viewModel.selectedState,
                    onStateSelected: { state in
                        viewModel.handleStateSelection(state, stateManager: stateManager) {
                            dismiss()
                        }
                    }
                )
                .padding(.horizontal)
            }
            .padding(.top, MainScreenConstants.adaptiveValue(16))
        }
        .background(Color(.systemBackground))
        .safeAreaInset(edge: .bottom) {
            VStack {
                Text("Ad Placeholder")
                    .font(.system(.caption, design: .rounded).weight(.medium))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: MainScreenConstants.adaptiveValue(60))
            .padding(.horizontal, MainScreenConstants.adaptiveValue(16))
            .padding(.bottom, MainScreenConstants.adaptiveValue(16))
            .background(
                RoundedRectangle(cornerRadius: MainScreenConstants.adaptiveValue(16))
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [6, 3]))
                    .foregroundColor(Color.green.opacity(0.7))
            )
            .background(Color(.systemBackground).ignoresSafeArea())
        }
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
