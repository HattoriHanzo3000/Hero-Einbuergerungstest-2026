import SwiftUI

/// About screen with mascot, description, and version info. Matches Hero B2 style.
struct SettingsAboutView: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                mascotImage
                descriptionCard
                versionText
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .navigationTitle("settings_about_button".localized)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var mascotImage: some View {
        Group {
            if UIImage(named: "MainChick") != nil {
                Image("MainChick")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: 200, maxHeight: 200)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("settings_about_heading".localized)
                .font(.headline)
                .foregroundStyle(.primary)

            Text("settings_about_description".localized)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var versionText: some View {
        Text("\("version".localized) \(appVersion)")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(16)
    }
}

#Preview("About") {
    NavigationStack {
        SettingsAboutView()
    }
}
