import SwiftUI

// Version information sheet
struct VersionSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            SetupHeader(title: "version", onDismiss: {
                dismiss()
            })
            
            ScrollView {
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
                    
                    // App Name
                    Text("Hero - Leben in Deutschland Test")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    // Version Content
                    VStack(alignment: .leading, spacing: 16) {
                        // Version Number
                        Text("\("version".localized) \(getAppVersion())")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        // Description
                        Text("version_description".localized)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Updates List
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(getUpdatesList(), id: \.self) { update in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Text(update.localized)
                                        .font(.system(size: 15, weight: .regular, design: .rounded))
                                        .foregroundColor(.primary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                }
                .padding(.top, 24)
            }
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
