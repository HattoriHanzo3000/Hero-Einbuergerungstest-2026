import SwiftUI
import UIKit
import CoreImage.CIFilterBuiltins

/// Share screen with QR code and share sheet. Matches Hero B2 style.
struct SettingsShareView: View {
    @State private var showShareSheet = false

    private let appStoreURL = "https://apps.apple.com/app/id6752272685"

    private var shareText: String {
        let appName = "Hero - Leben in Deutschland"
        return "\(appName)\n\(appStoreURL)"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                qrSection
                openInAppStoreButton
            }
            .padding(.vertical, 20)
            .padding(.bottom, 40)
        }
        .navigationTitle("settings_share_button".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    HapticManager.shared.lightImpact()
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body)
                        .foregroundStyle(.primary)
                }
                .accessibilityLabel("settings_share_button".localized)
                .accessibilityHint("share_app_hint".localized)
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
        VStack(spacing: 16) {
            Text("settings_share_scan_title".localized)
                .font(.system(.headline, design: .rounded).weight(.semibold))
                .foregroundStyle(.primary)

            SettingsQRCodeView(url: appStoreURL)
                .frame(width: 280, height: 280)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemBackground))
                )
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

            Text("settings_share_scan_subtitle".localized)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var openInAppStoreButton: some View {
        Button {
            HapticManager.shared.lightImpact()
            if let url = URL(string: appStoreURL) {
                UIApplication.shared.open(url)
            }
        } label: {
            Text("settings_open_app_store_button".localized)
                .font(.system(.body, design: .rounded).weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.accentColor)
                )
        }
        .padding(.horizontal)
    }
}

// MARK: - QR Code View

private struct SettingsQRCodeView: View {
    let url: String

    var body: some View {
        if let qrCodeImage = generateQRCode(from: url) {
            Image(uiImage: qrCodeImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "qrcode")
                .font(.system(size: 60))
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
    }
}
