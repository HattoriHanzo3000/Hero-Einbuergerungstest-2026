import SwiftUI
import UIKit

// MARK: - Onboarding Header Component (Island Design)
struct OnboardingHeaderComponent: View {
    let currentStep: Int
    let totalSteps: Int
    let messageKey: String
    let messageParameters: [String]?
    @Binding var showDialog: Bool
    let playSignal: UUID?
    let onPlayCompleted: (() -> Void)?
    
    private let standardPadding: CGFloat = 16
    fileprivate static let mascotAssetName = "MainChick"
    
    init(
        currentStep: Int,
        totalSteps: Int,
        messageKey: String,
        messageParameters: [String]? = nil,
        showDialog: Binding<Bool>,
        playSignal: UUID? = nil,
        onPlayCompleted: (() -> Void)? = nil
    ) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.messageKey = messageKey
        self.messageParameters = messageParameters
        self._showDialog = showDialog
        self.playSignal = playSignal
        self.onPlayCompleted = onPlayCompleted
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                ZStack {
                    ProgressView(value: Double(currentStep), total: Double(totalSteps))
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(.systemGray6)))
                        .frame(height: 8)
                        .clipShape(Capsule())
                }
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, OnboardingConstants.progressBarHorizontalPadding)
            }
            .frame(height: 44)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Progress")
            .accessibilityValue("\(currentStep) of \(totalSteps)")
            
            OnboardingMascotRow(
                messageKey: messageKey,
                messageParameters: messageParameters,
                horizontalPadding: standardPadding,
                playSignal: playSignal,
                onPlayCompleted: onPlayCompleted
            )
            .padding(.top, 12)
            .padding(.horizontal, standardPadding)
        }
        .padding(.bottom, standardPadding * 2)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.accentColor)
        )
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

// MARK: - Onboarding Mascot Dialog Row (Inside Header)
struct OnboardingMascotRow: View {
    let messageKey: String
    let messageParameters: [String]?
    let horizontalPadding: CGFloat
    @State private var showMascotGif = false
    @State private var gifPlayToken: UUID = UUID()
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    
    let playSignal: UUID?
    let onPlayCompleted: (() -> Void)?
    
    // MARK: - Constants
    private static let spacing: CGFloat = 16
    private static let mascotSize: CGFloat = 120
    private static let mascotShadowRadius: CGFloat = 4
    private static let mascotShadowOffset: CGSize = CGSize(width: 0, height: 2)
    private static let mascotShadowOpacity: Double = 0.1
    
    init(
        messageKey: String,
        messageParameters: [String]? = nil,
        horizontalPadding: CGFloat,
        playSignal: UUID? = nil,
        onPlayCompleted: (() -> Void)? = nil
    ) {
        self.messageKey = messageKey
        self.messageParameters = messageParameters
        self.horizontalPadding = horizontalPadding
        self.playSignal = playSignal
        self.onPlayCompleted = onPlayCompleted
    }
    
    private var formattedMessage: String {
        let localizedString = messageKey.localized
        guard let parameters = messageParameters, !parameters.isEmpty else { return localizedString }
        var formattedString = localizedString
        // Replace all occurrences of %d with parameters
        for parameter in parameters {
            formattedString = formattedString.replacingOccurrences(of: "%d", with: parameter)
        }
        return formattedString
    }
    
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
        HStack(alignment: .top, spacing: 0) {
            ZStack {
                if UIImage(named: staticMascotAssetName) != nil {
                    Image(staticMascotAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Self.mascotSize, height: Self.mascotSize)
                        .accessibilityLabel("Mascot")
                        .opacity((showMascotGif && !reduceMotion) ? 0 : 1)
                } else {
                    Color.clear
                        .frame(width: Self.mascotSize, height: Self.mascotSize)
                        .accessibilityHidden(true)
                }
                
                AnimatedGIFView(gifName: gifMascotAssetName, contentMode: .scaleAspectFit, shouldAnimate: showMascotGif && !reduceMotion)
                    .id(gifPlayToken)
                    .frame(width: Self.mascotSize, height: Self.mascotSize)
                    .accessibilityLabel("Mascot")
                    .opacity((showMascotGif && !reduceMotion) ? 1 : 0)
                    .allowsHitTesting(false)
            }
            .frame(width: Self.mascotSize, height: Self.mascotSize)
            .shadow(
                color: .black.opacity(Self.mascotShadowOpacity),
                radius: Self.mascotShadowRadius,
                x: Self.mascotShadowOffset.width,
                y: Self.mascotShadowOffset.height
            )
            .contentShape(Rectangle())
            .onTapGesture {
                HapticManager.shared.lightImpact()
                if !reduceMotion { playGifOnly() }
            }
            
            Spacer().frame(width: Self.spacing)

            VStack(alignment: .leading, spacing: 0) {
                Text(formattedMessage)
                    .font(.system(.subheadline, design: .rounded).weight(.regular))
                    .foregroundColor(.black)
                    .id(languageManager.currentAppLanguage)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, horizontalPadding)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black, lineWidth: 1))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .padding(.trailing, horizontalPadding)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onChange(of: playSignal) { _, _ in
            if reduceMotion {
                // Skip animation when reduce motion is enabled
                onPlayCompleted?()
            } else {
                // Play animation then complete
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
