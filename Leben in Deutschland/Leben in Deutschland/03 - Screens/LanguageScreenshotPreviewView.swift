//
//  LanguageScreenshotPreviewView.swift
//  Leben in Deutschland
//
//  Marketing / App Store screenshot layout only. Open from the Developer Menu (DEBUG).
//

#if DEBUG
import SwiftUI

// MARK: - Language Screenshot Preview (DEBUG)
/// Full-screen layout: mascot + headline, subtitle, language list; small X dismiss at bottom.
/// Flags use bundled PNGs (`ScreenshotFlag*`) — emoji text often renders as □/� in SwiftUI; assets are Twemoji (CC-BY 4.0).
struct LanguageScreenshotPreviewView: View {
    let onDismiss: () -> Void

    @Environment(\.layoutMetrics) private var layoutMetrics

    private static let languageRows: [(flagAsset: String, nativeName: String, accessibilityLabel: String)] = [
        ("ScreenshotFlagDE", "Deutsch", "Deutsch"),
        ("ScreenshotFlagGB", "English", "English"),
        ("ScreenshotFlagRU", "Русский", "Русский"),
        ("ScreenshotFlagTR", "Türkçe", "Türkçe")
    ]

    var body: some View {
        ZStack {
            Rectangle()
                .fill(LiquidGlassGradient.blue.screenBackground)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: layoutMetrics.adaptive(28)) {
                // Block 1: mascot + title
                VStack(spacing: layoutMetrics.adaptive(8)) {
                    HStack {
                        Spacer(minLength: 0)
                        MascotView(assetBaseName: "MainChick", autoPlayInterval: nil)
                            .fixedSize(horizontal: true, vertical: true)
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity)

                    Text("screenshot_languages_headline".localized)
                        .font(.system(.title, weight: .black))
                        .italic()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)
                        .accessibilityAddTraits(.isHeader)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, layoutMetrics.adaptive(24))

                // Block 2: subtitle (above languages)
                Text("screenshot_languages_subtitle".localized)
                    .font(.system(.headline, weight: .medium))
                    .foregroundColor(.white.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, layoutMetrics.adaptive(24))

                // Block 3: languages
                VStack(alignment: .leading, spacing: layoutMetrics.adaptive(16)) {
                    ForEach(Array(Self.languageRows.enumerated()), id: \.offset) { _, row in
                        HStack(alignment: .center, spacing: layoutMetrics.adaptive(14)) {
                            Image(row.flagAsset)
                                .resizable()
                                .interpolation(.high)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: layoutMetrics.adaptive(48), height: layoutMetrics.adaptive(44))
                                .accessibilityHidden(true)

                            Text(row.nativeName)
                                .font(.system(.title3, weight: .semibold).width(.expanded))
                                .foregroundColor(.white)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(row.accessibilityLabel)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, layoutMetrics.adaptive(24))

                Spacer(minLength: 0)

                Button {
                    HapticManager.shared.lightImpact()
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: layoutMetrics.adaptive(15), weight: .semibold))
                        .foregroundStyle(.white.opacity(0.88))
                        .frame(width: layoutMetrics.adaptive(32), height: layoutMetrics.adaptive(32))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .padding(.bottom, layoutMetrics.adaptive(8))
                .accessibilityLabel("close".localized)
            }
            .padding(.top, layoutMetrics.adaptive(24))
        }
    }
}

#Preview("Language screenshot (DEBUG)") {
    LanguageScreenshotPreviewView(onDismiss: {})
        .layoutMetrics(LayoutMetrics(scale: 1.0, screenSize: CGSize(width: 390, height: 844)))
}
#endif
