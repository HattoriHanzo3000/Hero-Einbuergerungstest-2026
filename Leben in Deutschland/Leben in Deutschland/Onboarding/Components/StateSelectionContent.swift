import SwiftUI

// MARK: - State Selection Content
struct StateSelectionContent: View {
    @Binding var selectedState: String?
    let onStateSelected: (String) -> Void
    @Binding var showDialog: Bool
    
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
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        onStateSelected(state)
                    }) {
                        Text(state.localized)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(selectedState == state ? .white : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 15)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedState == state ? Color.fill : Color(.unselected))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(width: OnboardingConstants.getButtonWidth())
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 16)
            .padding(.horizontal, 4)
        }
    }
}


