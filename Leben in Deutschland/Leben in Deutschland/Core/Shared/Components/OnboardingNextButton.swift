import SwiftUI

// MARK: - Onboarding Next Button
struct OnboardingNextButton: View {
    let isEnabled: Bool
    let action: () -> Void
    @Binding var showDialog: Bool
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        Button(action: {
            if isEnabled {
                HapticManager.shared.mediumImpact()
                action()
            }
        }) {
            Text("NEXT".localized)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color(.systemGray6))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isEnabled ? Color("AppOrange") : Color.gray)
                )
                .id(languageManager.currentAppLanguage)
        }
        .disabled(!isEnabled)
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
        .background(Color(.systemBackground))
    }
}
