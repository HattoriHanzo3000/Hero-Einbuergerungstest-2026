import SwiftUI
import UIKit
import CoreImage.CIFilterBuiltins

/// Share screen with QR code and share sheet. Matches Hero B2 style.
struct SettingsShareView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var showShareSheet = false

    private let appStoreURL = "https://apps.apple.com/app/id6752272685"

    private var shareText: String {
        let appName = "Hero - Leben in Deutschland"
        return "\(appName)\n\(appStoreURL)"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: layoutMetrics.adaptive(SettingsDesignTokens.Layout.sectionSpacing)) {
                qrSection
            }
            .padding(.horizontal, layoutMetrics.adaptive(20))
            .padding(.top, layoutMetrics.adaptive(20))
            .padding(.bottom, layoutMetrics.adaptive(40))
            .id(languageManager.currentAppLanguage)
        }
        .navigationTitle("settings_share_button".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                AdaptiveIconButton.backButton(action: { dismiss() }, tintColor: .primary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                AdaptiveIconButton(
                    systemName: "square.and.arrow.up",
                    action: { showShareSheet = true },
                    accessibilityLabel: "settings_share_button",
                    accessibilityHint: "share_app_hint",
                    tintColor: .primary
                )
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = URL(string: appStoreURL) {
                ShareSheet(activityItems: [shareText, url])
            } else {
                ShareSheet(activityItems: [shareText])
            }
        }
    }

    private var qrSection: some View {
        VStack(spacing: layoutMetrics.adaptive(SettingsDesignTokens.Layout.rowSpacing)) {
            Text("settings_share_scan_title".localized)
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)

            SettingsQRCodeView(url: appStoreURL)
                .frame(width: layoutMetrics.adaptive(280), height: layoutMetrics.adaptive(280))
                .padding(layoutMetrics.adaptive(16))
                .background(
                    RoundedRectangle(cornerRadius: layoutMetrics.adaptive(SettingsDesignTokens.Layout.cornerRadius), style: .continuous)
                        .fill(Color(.systemBackground))
                )
                .shadow(color: .black.opacity(0.1), radius: layoutMetrics.adaptive(8), x: 0, y: 4)
                .accessibilityLabel("settings_share_qr_accessibility".localized)

            Text("settings_share_scan_subtitle".localized)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
    }

}

// MARK: - QR Code View

private struct SettingsQRCodeView: View {
    let url: String
    @Environment(\.layoutMetrics) private var layoutMetrics

    var body: some View {
        if let qrCodeImage = generateQRCode(from: url) {
            Image(uiImage: qrCodeImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "qrcode")
                .font(.system(size: layoutMetrics.adaptive(60)))
                .foregroundStyle(.secondary)
        }
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(Data(string.utf8), forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        guard let outputImage = filter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview("Share") {
    NavigationStack {
        SettingsShareView()
            .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
    }
}
