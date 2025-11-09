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
            VStack(spacing: MainScreenConstants.adaptiveValue(16)) {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(states) { state in
                                stateButton(for: state)
                            }
                        }
                        .padding(.horizontal, MainScreenConstants.adaptiveValue(16))
                        .padding(.vertical, MainScreenConstants.adaptiveValue(16))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
            }
            .padding(.horizontal, 24)
            .padding(.top, MainScreenConstants.adaptiveValue(8))
            
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
                .font(.system(.body, design: .rounded).weight(.medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .rounded).weight(.medium))
                    .accessibilityLabel("Selected")
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.system(.body, design: .rounded).weight(.medium))
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

#Preview("Medium") {
    StateSelectionList(
        states: FederalStateModel.allStates,
        selectedState: "Berlin",
        onStateSelected: { _ in }
    )
    .environment(\.dynamicTypeSize, .medium)
}

#Preview("xxxLarge") {
    StateSelectionList(
        states: FederalStateModel.allStates,
        selectedState: "Berlin",
        onStateSelected: { _ in }
    )
    .environment(\.dynamicTypeSize, .xxxLarge)
}
