//
//  StateSelectionList.swift
//  Leben in Deutschland
//
//  List component for federal state selection
//

import SwiftUI

// MARK: - State Selection List
struct StateSelectionList: View {
    let states: [FederalStateModel]
    let selectedState: String?
    let onStateSelected: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 24) {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(states) { state in
                                stateButton(for: state)
                            }
                        }
                        .padding()
                        .padding(.bottom, 24)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            Spacer()
        }
    }
    
    // MARK: - State Button
    @ViewBuilder
    private func stateButton(for state: FederalStateModel) -> some View {
        StateButton(
            state: state,
            isSelected: selectedState == state.name,
            onTap: { onStateSelected(state.name) }
        )
    }
}

// MARK: - State Button Component
private struct StateButton: View {
    let state: FederalStateModel
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        HStack {
            Text(state.localizedName)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color("Fill"))
                    .font(.title2)
                    .accessibilityLabel("Selected")
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color("Fill"))
                    .font(.title2)
                    .opacity(0)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray5))
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.08), value: isPressed)
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {
            onTap()
        })
        .accessibilityLabel(state.localizedName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(isSelected ? "Currently selected state" : "Tap to select this state")
    }
}

// MARK: - Preview
#Preview {
    StateSelectionList(
        states: FederalStateModel.allStates,
        selectedState: "Berlin",
        onStateSelected: { _ in }
    )
}
