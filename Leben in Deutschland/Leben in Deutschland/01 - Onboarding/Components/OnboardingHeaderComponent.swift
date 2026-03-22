import SwiftUI
import UIKit

// MARK: - Onboarding Header Card (Liquid Glass, matches ScreenHeaderCard style)
struct OnboardingHeaderComponent: View {
    let currentStep: Int
    let totalSteps: Int
    let messageKey: String
    let messageParameters: [String]?
    let selectedState: String?
    @Binding var showDialog: Bool
    let playSignal: UUID?
    let onPlayCompleted: (() -> Void)?
    
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.layoutMetrics) private var layoutMetrics
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    
    fileprivate static let mascotAssetName = "MainChick"
    
    init(
        currentStep: Int,
        totalSteps: Int,
        messageKey: String,
        messageParameters: [String]? = nil,
        selectedState: String? = nil,
        showDialog: Binding<Bool>,
        playSignal: UUID? = nil,
        onPlayCompleted: (() -> Void)? = nil
    ) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.messageKey = messageKey
        self.messageParameters = messageParameters
        self.selectedState = selectedState
        self._showDialog = showDialog
        self.playSignal = playSignal
        self.onPlayCompleted = onPlayCompleted
    }
    
    private var verticalPadding: CGFloat { layoutMetrics.adaptive(18) }
    private var horizontalPadding: CGFloat { layoutMetrics.adaptive(20) }
    private var mascotToContentSpacing: CGFloat { layoutMetrics.adaptive(16) }
    private var titleToSloganSpacing: CGFloat { layoutMetrics.adaptive(6) }
    private var mascotSize: CGFloat { layoutMetrics.adaptive(120) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Progress bar (matches SpacedRepetitionQuestionCard: horizontal 20, vertical padding)
            ProgressView(value: Double(currentStep), total: Double(totalSteps))
                .progressViewStyle(LinearProgressViewStyle(tint: Color(.systemGray6)))
                .frame(height: layoutMetrics.adaptive(8))
                .clipShape(Capsule())
                .frame(maxWidth: .infinity)
                .padding(.horizontal, layoutMetrics.adaptive(20))
                .padding(.top, layoutMetrics.adaptive(18))
                .padding(.bottom, layoutMetrics.adaptive(12))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Progress")
                .accessibilityValue("\(currentStep) of \(totalSteps)")
            
            // Mascot + content row (same layout as ScreenHeaderCard)
            HStack(alignment: .center, spacing: mascotToContentSpacing) {
                OnboardingMascotView(
                    playSignal: playSignal,
                    onPlayCompleted: onPlayCompleted
                )
                .frame(width: mascotSize, height: mascotSize)
                
                if let selectedState = selectedState {
                    // With title: state name + slogan (ScreenHeaderCard style)
                    VStack(alignment: .leading, spacing: titleToSloganSpacing) {
                        Text(getLocalizedStateName(selectedState))
                            .font(.system(.title, weight: .heavy))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        OnboardingSloganBlock(stateName: selectedState, textColor: .white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    // Without title: message only (matches Categories mascot message)
                    Text(formattedMessage)
                        .font(.system(.body, weight: .semibold))
                        .italic()
                        .lineSpacing(4)
                        .foregroundColor(.white)
                        .id(languageManager.currentAppLanguage)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LiquidGlassBackground(gradient: .blue))
        .clipShape(RoundedRectangle(cornerRadius: layoutMetrics.adaptive(32), style: .continuous))
        .overlay(HeaderBorderOverlay())
        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
        .padding(.horizontal)
        .padding(.top, layoutMetrics.adaptive(8))
        .onChange(of: playSignal) { _, _ in
            if reduceMotion {
                onPlayCompleted?()
            } else {
                // Signal is handled by OnboardingMascotView
            }
        }
    }
    
    private var formattedMessage: String {
        // Onboarding copy follows the current app language (updates when user picks a language on step 1).
        let languageCode = languageManager.currentAppLanguage
        let localizedString = messageKey.localized(for: languageCode)
        guard let parameters = messageParameters, !parameters.isEmpty else { return localizedString }
        let locale = Locale(identifier: languageManager.currentAppLanguage)
        let formatArguments: [CVarArg] = parameters.map { parameter in
            if let intValue = Int(parameter) { return intValue }
            if let doubleValue = Double(parameter) { return Int(doubleValue.rounded()) }
            return parameter as NSString
        }
        return String(format: localizedString, locale: locale, arguments: formatArguments)
    }
    
    private func getLocalizedStateName(_ stateName: String) -> String {
        stateName.localized
    }
    
}

// MARK: - Onboarding Slogan Block (matches FederalStateSloganBlock, Categories mascot message)
private struct OnboardingSloganBlock: View {
    @EnvironmentObject private var languageManager: LanguageManager
    let stateName: String
    var textColor: Color = .white
    
    var body: some View {
        Text(localizedSlogan(for: stateName))
            .font(.system(.body, weight: .semibold))
            .italic()
            .lineSpacing(4)
            .foregroundColor(textColor)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel("main_header_state_slogan_accessibility_label".localized)
            .accessibilityValue(localizedSlogan(for: stateName))
            .id(languageManager.currentAppLanguage)
    }
    
    private func localizedSlogan(for state: String) -> String {
        let normalized = state
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
        let key = "state_\(normalized)_slogan"
        let localizedValue = key.localized
        if localizedValue == key {
            return "state_\(normalized)".localized
        }
        return localizedValue
    }
}

// MARK: - Onboarding Mascot View (tap to play GIF, matches MascotView layout)
private struct OnboardingMascotView: View {
    let playSignal: UUID?
    let onPlayCompleted: (() -> Void)?
    
    @State private var showMascotGif = false
    @State private var gifPlayToken: UUID = UUID()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    private var mascotSize: CGFloat { layoutMetrics.adaptive(120) }
    
    private var staticMascotAssetName: String {
        if colorScheme == .dark, UIImage(named: "MainChickDark") != nil {
            return "MainChickDark"
        }
        return OnboardingHeaderComponent.mascotAssetName
    }
    
    private var gifMascotAssetName: String {
        colorScheme == .dark ? "MainChickDark" : OnboardingHeaderComponent.mascotAssetName
    }
    
    var body: some View {
        ZStack {
            if UIImage(named: staticMascotAssetName) != nil {
                Image(staticMascotAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: mascotSize, height: mascotSize)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .accessibilityLabel("Mascot")
                    .opacity((showMascotGif && !reduceMotion) ? 0 : 1)
            } else {
                Color.clear
                    .frame(width: mascotSize, height: mascotSize)
                    .accessibilityHidden(true)
            }
            
            AnimatedGIFView(
                gifName: gifMascotAssetName,
                contentMode: .scaleAspectFit,
                shouldAnimate: showMascotGif && !reduceMotion
            )
            .id(gifPlayToken)
            .frame(width: mascotSize, height: mascotSize)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .accessibilityLabel("Mascot")
            .opacity((showMascotGif && !reduceMotion) ? 1 : 0)
            .allowsHitTesting(false)
        }
        .frame(width: mascotSize, height: mascotSize)
        .contentShape(Rectangle())
        .onTapGesture {
            HapticManager.shared.lightImpact()
            if reduceMotion {
                onPlayCompleted?()
            } else {
                playGifOnly()
            }
        }
        .onChange(of: playSignal) { _, _ in
            if reduceMotion {
                onPlayCompleted?()
            } else {
                playGifThenComplete()
            }
        }
    }
    
    private func playGifOnly() {
        gifPlayToken = UUID()
        showMascotGif = true
        DispatchQueue.main.asyncAfter(deadline: .now() + OnboardingConstants.gifAnimationDuration) {
            showMascotGif = false
        }
    }
    
    private func playGifThenComplete() {
        playGifOnly()
        DispatchQueue.main.asyncAfter(deadline: .now() + OnboardingConstants.gifAnimationDuration) {
            onPlayCompleted?()
        }
    }
}
