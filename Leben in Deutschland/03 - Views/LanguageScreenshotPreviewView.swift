//
//  LanguageScreenshotPreviewView.swift
//  Leben in Deutschland
//
//  Marketing / App Store screenshot layout only. Open from the Developer Menu (DEBUG).
//

#if DEBUG
import SwiftUI

// MARK: - Language Screenshot Preview (DEBUG)
/// Full-screen layout: mascot + headline, subtitle, language list. Tap headline to dismiss (DEBUG).
struct LanguageScreenshotPreviewView: View {
    let onDismiss: () -> Void

    @Environment(\.layoutMetrics) private var layoutMetrics

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
                        MascotView(autoPlayInterval: nil)
                            .fixedSize(horizontal: true, vertical: true)
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity)

                    Button {
                        HapticManager.shared.lightImpact()
                        onDismiss()
                    } label: {
                        Text("screenshot_languages_headline".localized)
                            .font(.system(.title, weight: .black))
                            .italic()
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel("screenshot_languages_headline".localized)
                    .accessibilityHint("close".localized)
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

                // Block 3: languages (native names only; ISO 639-1 order via LanguageOption)
                VStack(alignment: .leading, spacing: layoutMetrics.adaptive(16)) {
                    ForEach(LanguageOption.languagesInDisplayOrder) { language in
                        Text(language.nativeName)
                            .font(.system(.title3, weight: .semibold).width(.expanded))
                            .foregroundColor(.white)
                            .accessibilityLabel(language.nativeName)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, layoutMetrics.adaptive(24))

                Spacer(minLength: 0)
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
