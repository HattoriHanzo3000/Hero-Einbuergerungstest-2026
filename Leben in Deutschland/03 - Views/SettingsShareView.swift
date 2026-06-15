import SwiftUI
import UIKit
import CoreImage.CIFilterBuiltins

/// Share screen with QR code and share sheet. Matches Hero B2 style.
struct SettingsShareView: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var showShareSheet = false

    private var shareText: String {
        let appName = "Hero – Einbürgerungstest"
        return "\(appName)\n\(AppURLs.appStoreURL.absoluteString)"
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(LiquidGlassGradient.blue.screenBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: layoutMetrics.adaptive(SettingsDesignTokens.Layout.sectionSpacing)) {
                    qrSection
                }
                .padding(.horizontal, layoutMetrics.adaptive(20))
                .padding(.top, layoutMetrics.adaptive(20))
                .padding(.bottom, layoutMetrics.adaptive(40))
                .id(languageManager.currentAppLanguage)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("settings_share_button".localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    HapticManager.shared.lightImpact()
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .tint(.primary)
                .accessibilityLabel("settings_share_button".localized)
                .accessibilityHint("share_app_hint".localized)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [shareText])
        }
    }

    private var qrSection: some View {
        VStack(spacing: layoutMetrics.adaptive(20)) {
            SettingsQRCodeView(url: AppURLs.appStoreURL.absoluteString)
                .frame(width: layoutMetrics.adaptive(280), height: layoutMetrics.adaptive(280))
                .padding(layoutMetrics.adaptive(16))
                .background(
                    RoundedRectangle(cornerRadius: layoutMetrics.adaptive(SettingsDesignTokens.Layout.cornerRadius), style: .continuous)
                        .fill(Color(.systemBackground))
                )
                .shadow(color: .black.opacity(0.1), radius: layoutMetrics.adaptive(8), x: 0, y: 4)
                .accessibilityLabel("settings_share_qr_accessibility".localized)

            Text("settings_share_scan_subtitle".localized)
                .font(.body)
                .foregroundStyle(.white.opacity(0.95))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
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
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        let extent = scaledImage.extent
        let normalized = scaledImage.transformed(
            by: CGAffineTransform(translationX: -extent.origin.x, y: -extent.origin.y)
        )
        let bounds = CGRect(origin: .zero, size: extent.size)
        guard let cgImage = context.createCGImage(normalized, from: bounds) else { return nil }
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
            .environmentObject(LanguageManager())
            .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
    }
}
