import SwiftUI

// MARK: - App Rating Prompt View
/// A friendly, funny prompt asking users to rate the app
struct AppRatingPromptView: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var languageManager: LanguageManager
    @ObservedObject private var ratingManager: AppRatingManager
    
    let onRateNow: () -> Void
    let onAskLater: () -> Void
    
    init(
        ratingManager: AppRatingManager = .shared,
        onRateNow: @escaping () -> Void,
        onAskLater: @escaping () -> Void
    ) {
        self.ratingManager = ratingManager
        self.onRateNow = onRateNow
        self.onAskLater = onAskLater
    }

    private var ratingMascotAssetName: String {
        if colorScheme == .dark, UIImage(named: "MainChick_AboutDark") != nil {
            return "MainChick_AboutDark"
        }
        return "MainChick_About"
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: layoutMetrics.adaptive(24)) {
                // Mascot (MainChick_About from assets)
                Image(ratingMascotAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: layoutMetrics.adaptive(80), height: layoutMetrics.adaptive(80))
                    .accessibilityLabel("settings_about_mascot_accessibility".localized)
                
                // Title
                Text("rating_prompt_title".localized)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, layoutMetrics.adaptive(20))
                
                // Message
                Text("rating_prompt_message".localized)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, layoutMetrics.adaptive(20))
                
                // Buttons
                VStack(spacing: layoutMetrics.adaptive(12)) {
                    // "Do it now" button
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        onRateNow()
                    }) {
                        Text("rating_prompt_rate_now".localized)
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, layoutMetrics.adaptive(16))
                            .background(Color("AppOrange"))
                            .cornerRadius(layoutMetrics.adaptive(14))
                    }
                    .buttonStyle(.plain)
                    
                    // "Ask later" button
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        onAskLater()
                    }) {
                        Text("rating_prompt_ask_later".localized)
                            .font(.body.weight(.medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, layoutMetrics.adaptive(14))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, layoutMetrics.adaptive(20))
                .padding(.top, layoutMetrics.adaptive(8))
            }
            .padding(.vertical, layoutMetrics.adaptive(32))
            .background(
                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(20))
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, layoutMetrics.adaptive(24))
            
            Spacer()
        }
        .background(
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // Dismiss on background tap (same as "Ask later")
                    onAskLater()
                }
        )
    }
}

// MARK: - Preview
#Preview {
    AppRatingPromptView(
        onRateNow: {},
        onAskLater: {}
    )
    .environmentObject(LanguageManager())
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

