import SwiftUI

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
                .padding(.horizontal, standardPadding)
                .border(Color.yellow.opacity(0), width: 2)
            }
            .frame(height: 44)
            .border(Color.green.opacity(0), width: 2)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Progress")
            .accessibilityValue("\(currentStep) of \(totalSteps)")
            
            OnboardingMascotRow(
                messageKey: messageKey,
                messageParameters: messageParameters,
                showDialog: $showDialog,
                horizontalPadding: standardPadding,
                playSignal: playSignal,
                onPlayCompleted: onPlayCompleted
            )
            .padding(.top, 12)
            .padding(.horizontal, standardPadding)
            .border(Color.orange.opacity(0), width: 2)
        }
        .padding(.bottom, standardPadding * 2)
        .border(Color.blue.opacity(0), width: 2)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.accentColor)
                .border(Color.red.opacity(0), width: 2)
        )
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private func circleIconButton(icon: String, tint: Color = Color.accentColor) -> some View {
        ZStack {
            Circle()
                .fill(Color("MainButton"))
                .frame(width: 30, height: 30)
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(tint)
        }
        .frame(width: 44, height: 44)
        .contentShape(Circle())
    }
}

// MARK: - Onboarding Mascot Row (Inside Header)
struct OnboardingMascotRow: View {
    let messageKey: String
    let messageParameters: [String]?
    @Binding var showDialog: Bool
    let horizontalPadding: CGFloat
    @State private var showMascotGif = false
    @State private var gifPlayToken: UUID = UUID()
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    let playSignal: UUID?
    let onPlayCompleted: (() -> Void)?
    
    init(
        messageKey: String,
        messageParameters: [String]? = nil,
        showDialog: Binding<Bool>,
        horizontalPadding: CGFloat,
        playSignal: UUID? = nil,
        onPlayCompleted: (() -> Void)? = nil
    ) {
        self.messageKey = messageKey
        self.messageParameters = messageParameters
        self._showDialog = showDialog
        self.horizontalPadding = horizontalPadding
        self.playSignal = playSignal
        self.onPlayCompleted = onPlayCompleted
    }
    
    private var formattedMessage: String {
        let localizedString = messageKey.localized
        guard let parameters = messageParameters, !parameters.isEmpty else { return localizedString }
        var formattedString = localizedString
        for (_, parameter) in parameters.enumerated() {
            if let range = formattedString.range(of: "%d") {
                formattedString = formattedString.replacingOccurrences(of: "%d", with: parameter, range: range)
            }
        }
        return formattedString
    }
    
    var body: some View {
        let spacing: CGFloat = 16
        let mascotSize: CGFloat = 120
        
        HStack(alignment: .top, spacing: 0) {
            ZStack {
                if UIImage(named: "MainChick") != nil {
                    Image("MainChick")
                        .resizable()
                        .scaledToFit()
                        .frame(height: mascotSize)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .accessibilityLabel("Mascot")
                        .opacity((showMascotGif && !reduceMotion) ? 0 : 1)
                } else {
                    Color.clear
                        .frame(width: mascotSize, height: mascotSize)
                        .accessibilityHidden(true)
                }
                
                let gifName = "MainChick"
                AnimatedGIFView(gifName: gifName, contentMode: .scaleAspectFit, shouldAnimate: showMascotGif && !reduceMotion)
                    .id(gifPlayToken)
                    .frame(width: mascotSize, height: mascotSize)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .accessibilityLabel("Mascot")
                    .opacity((showMascotGif && !reduceMotion) ? 1 : 0)
                    .allowsHitTesting(false)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                HapticManager.shared.lightImpact()
                if !reduceMotion { playGifOnly() }
            }
            .border(Color.pink.opacity(0), width: 2)
            
            Spacer().frame(width: spacing)

            VStack(alignment: .leading, spacing: 0) {
                Text(formattedMessage)
                    .font(.callout)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
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
            .border(Color.cyan.opacity(0), width: 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .border(Color.purple.opacity(0), width: 2)
        .onChange(of: playSignal) { _, _ in
            if reduceMotion { onPlayCompleted?() } else { playGifThenComplete() }
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


