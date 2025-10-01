import SwiftUI

// MARK: - Onboarding Mascot Dialog
struct OnboardingMascotDialog: View {
    let messageKey: String
    let messageParameters: [String]?
    @Binding var showDialog: Bool
    @State private var showMascotGif = false
    @State private var gifPlayToken: UUID = UUID()
    @EnvironmentObject var languageManager: LanguageManager
    
    // External playback trigger and completion callback
    let playSignal: UUID?
    let onPlayCompleted: (() -> Void)?
    
    init(messageKey: String, showDialog: Binding<Bool>, playSignal: UUID? = nil, onPlayCompleted: (() -> Void)? = nil) {
        self.messageKey = messageKey
        self.messageParameters = nil
        self._showDialog = showDialog
        self.playSignal = playSignal
        self.onPlayCompleted = onPlayCompleted
    }
    
    init(messageKey: String, messageParameters: [String], showDialog: Binding<Bool>, playSignal: UUID? = nil, onPlayCompleted: (() -> Void)? = nil) {
        self.messageKey = messageKey
        self.messageParameters = messageParameters
        self._showDialog = showDialog
        self.playSignal = playSignal
        self.onPlayCompleted = onPlayCompleted
    }
    
    private var formattedMessage: String {
        let localizedString = messageKey.localized
        guard let parameters = messageParameters, !parameters.isEmpty else {
            return localizedString
        }
        
        // Format the string with parameters (e.g., %d -> actual number)
        var formattedString = localizedString
        for (_, parameter) in parameters.enumerated() {
            let placeholder = "%d"
            if let range = formattedString.range(of: placeholder) {
                formattedString = formattedString.replacingOccurrences(of: placeholder, with: parameter, range: range)
            }
        }
        return formattedString
    }
    
    var body: some View {
        GeometryReader { geometry in
            let sidePadding = OnboardingConstants.getSidePadding()
            let bubbleWidth = OnboardingConstants.getBubbleWidth()
            let mascotSize = OnboardingConstants.getEmojiSize()
            let _: CGFloat = 12 // Must match DialogBubbleShape's tail width
            let spacing: CGFloat = 12
            
            HStack(alignment: .center, spacing: spacing) {

                // MARK: - Mascot (GIF preferred, fallback to static image)
                ZStack {
                    if showMascotGif {
                        let gifName = UITraitCollection.current.userInterfaceStyle == .dark ? "MainChickDark" : "MainChick"
                        if let _ = Bundle.main.url(forResource: gifName, withExtension: "gif") {
                            AnimatedGIFView(gifName: gifName)
                                .id(gifPlayToken)
                                .frame(width: mascotSize, height: mascotSize)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                .accessibilityLabel("Mascot")
                        }
                    } else if UIImage(named: "MainChick") != nil {
                        Image("MainChick")
                            .resizable()
                            .scaledToFit()
                            .frame(width: mascotSize, height: mascotSize)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            .accessibilityLabel("Mascot")
                    } else {
                        Color.clear
                            .frame(width: mascotSize, height: mascotSize)
                            .accessibilityHidden(true)
                    }
                }
                .frame(width: mascotSize, height: mascotSize)
                .contentShape(Rectangle())
                .onTapGesture {
                    HapticManager.shared.lightImpact()
                    playGifOnly()
                }

                // MARK: - Dialog Bubble
                VStack(alignment: .leading, spacing: 8) {
                    Text(formattedMessage)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                        .id(languageManager.currentAppLanguage)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(width: bubbleWidth - 10) // Subtract tail width for content
                .offset(x: 10) // Offset content to the right to account for tail
                .background(
                    DialogBubbleShape()
                        .fill(Color(.systemGray6))
                        .overlay(
                            DialogBubbleShape()
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                
                Spacer(minLength: sidePadding)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.trailing, sidePadding)
        }
        .frame(height: OnboardingConstants.getMascotHeight())
        .background(
            RoundedRectangle(cornerRadius: 0, style: .continuous)
                .fill(Color("Fill"))
                .clipShape(
                    RoundedCorner(radius: 35, corners: [.bottomLeft, .bottomRight])
                )
        )
        // Play when external signal changes
        .onChange(of: playSignal) {
            playGifThenComplete()
        }
    }
    
    private func playGifOnly() {
        showMascotGif = true
        gifPlayToken = UUID()
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
