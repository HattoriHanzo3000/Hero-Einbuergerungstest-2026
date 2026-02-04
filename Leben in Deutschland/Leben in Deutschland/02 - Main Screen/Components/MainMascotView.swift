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
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    // External playback trigger and completion callback
    let playSignal: UUID?
    let onPlayCompleted: (() -> Void)?
    /// When true, shows only mascot + plain text (no speech bubble).
    let hideBubble: Bool
    /// When hideBubble is true, use this color for the text (default: systemGray6). Use .white for dark headers.
    let plainTextColor: Color?

    init(
        messageKey: String,
        messageParameters: [String]? = nil,
        leadingMessage: String? = nil,
        showDialog: Binding<Bool>,
        autoPlayInterval: TimeInterval? = nil,
        playSignal: UUID? = nil,
        onPlayCompleted: (() -> Void)? = nil,
        hideBubble: Bool = false,
        plainTextColor: Color? = nil
    ) {
        self.messageKey = messageKey
        self.messageParameters = messageParameters
        self.leadingMessage = leadingMessage
        self._showDialog = showDialog
        self.autoPlayInterval = autoPlayInterval
        self.playSignal = playSignal
        self.onPlayCompleted = onPlayCompleted
        self.hideBubble = hideBubble
        self.plainTextColor = plainTextColor
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
        HStack(alignment: .center, spacing: spacing) {
            VStack(spacing: 0) {
                Spacer()
                mascotView
                Spacer()
            }
            
            if hideBubble {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    Text(combinedMessage)
                        .font(.system(.body, design: .rounded).weight(.medium))
                        .lineSpacing(4)
                        .foregroundColor(plainTextColor ?? Color(.systemGray6))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .id(languageManager.currentAppLanguage)
                    Spacer()
                }
            } else {
                VStack(spacing: 0) {
                    Spacer()
                    dialogBubble
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, hideBubble ? 0 : trailingInset)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + LayoutMetrics.gifAnimationDuration) {
            showMascotGif = false
        }
    }

    private func playGifThenComplete() {
        playGifOnly()
        DispatchQueue.main.asyncAfter(deadline: .now() + LayoutMetrics.gifAnimationDuration) {
            onPlayCompleted?()
        }
    }
}

// MARK: - Private Helpers
private extension MainMascotView {
    var spacing: CGFloat { layoutMetrics.adaptive(16) }
    var mascotSize: CGFloat { layoutMetrics.adaptive(120) }
    var mascotCornerRadius: CGFloat { layoutMetrics.adaptive(24) }
    var bubbleCornerRadius: CGFloat { layoutMetrics.adaptive(16) }
    var trailingInset: CGFloat { layoutMetrics.adaptive(20) }
    
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
    }
    
    var dialogBubble: some View {
        VStack(alignment: .leading, spacing: layoutMetrics.adaptive(6)) {
            Text(combinedMessage)
                .font(.system(.body, design: .rounded).weight(.medium))
                .lineSpacing(4)
                .foregroundColor(Color.primary.opacity(0.88))
                .id(languageManager.currentAppLanguage)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .dynamicTypeSize(.large)
        }
        .padding(.horizontal, layoutMetrics.adaptive(18))
        .padding(.vertical, layoutMetrics.adaptive(14))
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(bubbleBackground)
        .overlay(bubbleHighlight)
        .overlay(bubbleStroke)
        .innerShadow(shape: RoundedRectangle(cornerRadius: bubbleCornerRadius), color: Color.black.opacity(0.08), lineWidth: 1, blur: 2, offset: CGSize(width: 0, height: 1))
    }
    
    var bubbleBackground: some View {
        RoundedRectangle(cornerRadius: bubbleCornerRadius)
            .fill(Color(.secondarySystemGroupedBackground))
    }
    
    var bubbleHighlight: some View {
        RoundedRectangle(cornerRadius: bubbleCornerRadius)
        .stroke(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.35),
                    Color.white.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: 0.75
        )
        .blendMode(.screen)
    }
    var bubbleStroke: some View {
        RoundedRectangle(cornerRadius: bubbleCornerRadius)
        .stroke(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.12),
                    Color.white.opacity(0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: 0.75
        )
        .blendMode(.overlay)
    }
}

// MARK: - Inner Shadow Modifier
private extension View {
    func innerShadow<S: Shape>(
        shape: S,
        color: Color,
        lineWidth: CGFloat,
        blur: CGFloat,
        offset: CGSize
    ) -> some View {
        self
            .overlay(
                shape
                    .stroke(color, lineWidth: lineWidth)
                    .blur(radius: blur)
                    .offset(offset)
                    .mask(shape.fill(style: FillStyle(eoFill: true)))
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
