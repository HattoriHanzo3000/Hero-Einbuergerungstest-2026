import SwiftUI

// MARK: - Main Mascot View
struct MainMascotView: View {
    @Binding var showDialog: Bool
    let messageKey: String
    let messageParameters: [String]?
    let horizontalPadding: CGFloat
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
        self.horizontalPadding = 0 // Not used anymore, padding handled by parent
        self.playSignal = playSignal
        self.onPlayCompleted = onPlayCompleted
    }
    
    init(messageKey: String, messageParameters: [String], showDialog: Binding<Bool>, playSignal: UUID? = nil, onPlayCompleted: (() -> Void)? = nil) {
        self.messageKey = messageKey
        self.messageParameters = messageParameters
        self._showDialog = showDialog
        self.horizontalPadding = 0 // Not used anymore, padding handled by parent
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
            let standardPadding: CGFloat = 16
            let spacing: CGFloat = 16 // Increased spacing between mascot and bubble
            // Mascot size - fixed
            let mascotSize: CGFloat = 120
            
            HStack(alignment: .center, spacing: spacing) {
                // MARK: - Mascot (GIF preferred, fallback to static image)
                ZStack {
                    // Base static image always visible
                    if UIImage(named: "MainChick") != nil {
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

                    // GIF overlay shown when playing (same asset for light/dark)
                    let gifName = "MainChick"
                    AnimatedGIFView(gifName: gifName, shouldAnimate: showMascotGif)
                        .id(gifPlayToken)
                        .frame(width: mascotSize, height: mascotSize)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .accessibilityLabel("Mascot")
                        .opacity(showMascotGif ? 1 : 0)
                        .allowsHitTesting(false)
                }
                .frame(width: mascotSize, height: mascotSize)
                .contentShape(Rectangle())
                .onTapGesture {
                    HapticManager.shared.lightImpact()
                    playGifOnly()
                }

                // MARK: - Dialog Bubble (no tail, dynamic height, centered with mascot)
                VStack(alignment: .leading, spacing: 0) {
                    Text(formattedMessage)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                        .id(languageManager.currentAppLanguage)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                .frame(maxHeight: mascotSize) // Max height to match mascot, but can be smaller
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                
                // Padding after bubble before right edge
                Spacer()
                    .frame(width: standardPadding)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        // Play when external signal changes
        .onChange(of: playSignal) { _, _ in
            playGifThenComplete()
        }
    }
    
    private func playGifOnly() {
        gifPlayToken = UUID()
        showMascotGif = true
        DispatchQueue.main.asyncAfter(deadline: .now() + MainScreenConstants.gifAnimationDuration) {
            showMascotGif = false
        }
    }

    private func playGifThenComplete() {
        playGifOnly()
        DispatchQueue.main.asyncAfter(deadline: .now() + MainScreenConstants.gifAnimationDuration) {
            onPlayCompleted?()
        }
    }
}

// MARK: - Preview
#Preview {
    MainMascotView(
        messageKey: "eagle_desc_chick",
        showDialog: .constant(true)
    )
    .environmentObject(LanguageManager())
    .frame(height: 120)
}
