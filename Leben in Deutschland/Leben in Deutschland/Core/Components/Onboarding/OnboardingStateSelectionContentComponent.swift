import SwiftUI

// MARK: - Onboarding State Selection Content Component
struct OnboardingStateSelectionContentComponent: View {
    @Binding var selectedState: String?
    let onStateSelected: (String) -> Void
    
    private let states: [String] = [
        "Baden-Württemberg",
        "Bayern",
        "Berlin",
        "Brandenburg",
        "Bremen",
        "Hamburg",
        "Hessen",
        "Mecklenburg-Vorpommern",
        "Niedersachsen",
        "Nordrhein-Westfalen",
        "Rheinland-Pfalz",
        "Saarland",
        "Sachsen",
        "Sachsen-Anhalt",
        "Schleswig-Holstein",
        "Thüringen"
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: OnboardingConstants.defaultSpacing) {
                ForEach(states, id: \.self) { state in
                    OnboardingStateOptionRowComponent(
                        state: state,
                        isSelected: selectedState == state,
                        onTap: {
                            HapticManager.shared.lightImpact()
                            onStateSelected(state)
                        }
                    )
                }
            }
            .transaction { t in t.animation = nil }
            .frame(width: OnboardingConstants.getButtonWidth())
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 16)
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - State Option Row (with press animation)
private struct OnboardingStateOptionRowComponent: View {
    let state: String
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            Text(state.localized)
                .font(.body)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 56)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.accentColor : Color("Unselected"))
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .buttonPressAnimation(isPressed: $isPressed)
    }
}
