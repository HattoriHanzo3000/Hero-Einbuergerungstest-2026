import SwiftUI
import UIKit

// MARK: - Main Mascot View
struct MainMascotView: View {
    @Binding var showDialog: Bool
    let messageKey: String
    let messageParameters: [String]?
    let leadingMessage: String?
    let autoPlayInterval: TimeInterval?
    @State private var showMascotGif = false
    @State private var gifPlayToken: UUID = UUID()
    @State private var autoPlayTask: Task<Void, Never>? = nil
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    
    // External playback trigger and completion callback
    let playSignal: UUID?
    let onPlayCompleted: (() -> Void)?
    
    init(
        messageKey: String,
        messageParameters: [String]? = nil,
        leadingMessage: String? = nil,
        showDialog: Binding<Bool>,
        autoPlayInterval: TimeInterval? = nil,
        playSignal: UUID? = nil,
        onPlayCompleted: (() -> Void)? = nil
    ) {
        self.messageKey = messageKey
        self.messageParameters = messageParameters
        self.leadingMessage = leadingMessage
        self._showDialog = showDialog
        self.autoPlayInterval = autoPlayInterval
        self.playSignal = playSignal
        self.onPlayCompleted = onPlayCompleted
    }
    
    private var formattedMessage: String {
        let localizedString = messageKey.localized
        guard let parameters = messageParameters, !parameters.isEmpty else {
            return localizedString
        }
        
        let locale = Locale(identifier: languageManager.currentAppLanguage)
        let formatArguments: [CVarArg] = parameters.map { parameter in
            if let intValue = Int(parameter) {
                return intValue
            }
            if let doubleValue = Double(parameter) {
                return doubleValue
            }
            return parameter as NSString
        }
        
        return String(format: localizedString, locale: locale, arguments: formatArguments)
    }
    
    private var combinedMessage: String {
        guard let leading = leadingMessage, !leading.isEmpty else {
            return formattedMessage
        }
        return "\(leading) \(formattedMessage)"
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: Self.spacing) {
            mascotView
            
            dialogBubble
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, Self.trailingInset)
        .onChange(of: playSignal) { _, _ in
            if reduceMotion {
                onPlayCompleted?()
            } else {
                playGifThenComplete()
            }
        }
        .onAppear {
            guard let interval = autoPlayInterval else { return }
            autoPlayTask?.cancel()
            autoPlayTask = Task<Void, Never> { [reduceMotion] in
                guard !reduceMotion else { return }
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                    if Task.isCancelled { break }
                    await MainActor.run {
                        playGifOnly()
                    }
                }
            }
        }
        .onDisappear {
            autoPlayTask?.cancel()
            autoPlayTask = nil
        }
    }
    
    private func playGifOnly() {
        guard !reduceMotion else { return }
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

// MARK: - Private Helpers
private extension MainMascotView {
    static var spacing: CGFloat { MainScreenConstants.adaptiveValue(16) }
    static var mascotSize: CGFloat { MainScreenConstants.adaptiveValue(120) }
    static var mascotCornerRadius: CGFloat { MainScreenConstants.adaptiveValue(24) }
    static var bubbleCornerRadius: CGFloat { MainScreenConstants.adaptiveValue(16) }
    static var trailingInset: CGFloat { MainScreenConstants.adaptiveValue(20) }
    
    var staticMascotAssetName: String {
        if colorScheme == .dark, UIImage(named: "MainChickDark") != nil {
            return "MainChickDark"
        }
        return "MainChick"
    }
    
    var gifMascotAssetName: String {
        if colorScheme == .dark, gifExists(named: "MainChickDark") {
            return "MainChickDark"
        }
        return "MainChick"
    }
    
    var mascotView: some View {
        ZStack {
            if UIImage(named: staticMascotAssetName) != nil {
                Image(staticMascotAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Self.mascotSize, height: Self.mascotSize)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .accessibilityLabel("Mascot")
                    .opacity((showMascotGif && !reduceMotion) ? 0 : 1)
            } else {
                Color.clear
                    .frame(width: Self.mascotSize, height: Self.mascotSize)
                    .accessibilityHidden(true)
            }
            
            AnimatedGIFView(
                gifName: gifMascotAssetName,
                contentMode: .scaleAspectFit,
                shouldAnimate: showMascotGif && !reduceMotion
            )
            .id(gifPlayToken)
            .frame(width: Self.mascotSize, height: Self.mascotSize)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .accessibilityLabel("Mascot")
            .opacity((showMascotGif && !reduceMotion) ? 1 : 0)
            .allowsHitTesting(false)
        }
        .frame(width: Self.mascotSize, height: Self.mascotSize)
        .contentShape(Rectangle())
        .onTapGesture {
            HapticManager.shared.lightImpact()
            if reduceMotion {
                onPlayCompleted?()
            } else {
                playGifOnly()
            }
        }
    }
    
    var dialogBubble: some View {
            VStack(alignment: .leading, spacing: 0) {
        Text(combinedMessage)
            .font(.system(.subheadline, design: .rounded).weight(.regular))
                .foregroundColor(.black)
                .id(languageManager.currentAppLanguage)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: Self.bubbleCornerRadius)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: Self.bubbleCornerRadius)
                        .stroke(Color.black, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Resource Helpers
private extension MainMascotView {
    func gifExists(named name: String) -> Bool {
        let subdirectories: [String?] = [nil, "Resources/GIFs", "GIFs"]
        for subdirectory in subdirectories {
            if Bundle.main.url(forResource: name, withExtension: "gif", subdirectory: subdirectory) != nil {
                return true
            }
        }
        return false
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
