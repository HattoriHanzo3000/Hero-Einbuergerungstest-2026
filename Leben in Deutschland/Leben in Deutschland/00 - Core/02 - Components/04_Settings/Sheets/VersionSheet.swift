import SwiftUI

// Version information sheet
struct VersionSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: MainScreenConstants.adaptiveValue(28)) {
                // Header
                SetupHeader(title: "version", onDismiss: {
                    dismiss()
                })
                
                VStack(spacing: 24) {
                    // App Icon
                    Image("Logo")
                        .resizable()
                        .interpolation(.high)
                        .antialiased(true)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    // App Information
                    VStack(alignment: .leading, spacing: 16) {
                        // App Name
                        Text("Hero - Leben in Deutschland Test")
                            .font(.system(.title2, design: .rounded).weight(.bold))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Version Number
                        Text("\("version".localized) \(getAppVersion())")
                            .font(.system(.body, design: .rounded).weight(.semibold))
                            .foregroundColor(.primary)
                        
                        // Description
                        Text("version_description".localized)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Updates List
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(getUpdatesList(), id: \.self) { update in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .font(.system(.body, design: .rounded).weight(.semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text(update.localized)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(.primary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, MainScreenConstants.adaptiveValue(24))
                }
                .padding(.top, MainScreenConstants.adaptiveValue(16))
            }
            .padding(.top, MainScreenConstants.adaptiveValue(16))
        }
        .background(Color(.systemBackground))
    }
    
    // Get app version
    private func getAppVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    // Get updates list
    private func getUpdatesList() -> [String] {
        return [
            "update_1",
            "update_2",
            "update_3",
            "update_4",
            "update_5"
        ]
    }
}

// MARK: - Previews
#Preview {
    VersionSheet()
        .environmentObject(StateManager())
        .environmentObject(LanguageManager())
}
