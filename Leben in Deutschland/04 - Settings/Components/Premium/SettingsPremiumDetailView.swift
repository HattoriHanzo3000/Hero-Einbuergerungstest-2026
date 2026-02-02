import SwiftUI

struct SettingsPremiumDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("premium_title".localized)
                    .font(.largeTitle.weight(.bold))
                    .accessibilityAddTraits(.isHeader)
                Text("premium_description".localized)
                    .font(.body)
                    .foregroundStyle(.secondary)
                Button {
                    HapticManager.shared.successImpact()
                } label: {
                    Text("premium_cta_button".localized)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(RoundedRectangle(cornerRadius: SettingsDesignTokens.Layout.cornerRadius))
            }
            .padding()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("settings_premium_title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Analytics or fetch hooks can be added here later.
        }
    }
}

#Preview("Premium Detail") {
    NavigationStack {
        SettingsPremiumDetailView()
    }
}

