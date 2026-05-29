import SwiftUI

// MARK: - Onboarding State Selection Content Component
struct OnboardingStateSelectionContentComponent: View {
    @Binding var selectedState: String?
    let onStateSelected: (String) -> Void
    @Environment(\.layoutMetrics) private var layoutMetrics
    
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
            .frame(width: layoutMetrics.screenWidth * OnboardingConstants.buttonWidthRatio)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 16)
            .padding(.horizontal, 4)
    }
}

// MARK: - State Option Row (QuizAnswerOptionButton style)
private struct OnboardingStateOptionRowComponent: View {
    let state: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        QuizAnswerOptionButton(
            primaryText: state.localized,
            state: isSelected ? .selected : .neutral,
            suppressGlow: true,
            action: onTap
        )
    }
}
