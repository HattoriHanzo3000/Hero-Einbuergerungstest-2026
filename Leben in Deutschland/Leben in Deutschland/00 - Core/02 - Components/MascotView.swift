import SwiftUI
import UIKit

// MARK: - Mascot View
/// Shows the Hero eagle mascot with optional GIF animation on tap or auto-play.
/// Used in headers (Home, Test, Progress, Categories, Test Results).
struct MascotView: View {
    /// Base name for the mascot asset, e.g. "MainChick" or "MainChickFlipped".
    /// Dark variants use the "Dark" suffix when available (e.g. "MainChickDark").
    let assetBaseName: String
    let autoPlayInterval: TimeInterval?
    let playSignal: UUID?
    let onPlayCompleted: (() -> Void)?
    /// Called when mascot GIF animation starts (tap or auto-play). Use to sync UI (e.g. alternate header message).
    let onAnimationStart: (() -> Void)?

    @State private var showMascotGif = false
    @State private var gifPlayToken: UUID = UUID()
    @State private var autoPlayTask: Task<Void, Never>? = nil
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.layoutMetrics) private var layoutMetrics

    init(
        assetBaseName: String = "MainChick",
        autoPlayInterval: TimeInterval? = nil,
        playSignal: UUID? = nil,
        onPlayCompleted: (() -> Void)? = nil,
        onAnimationStart: (() -> Void)? = nil
    ) {
        self.assetBaseName = assetBaseName
        self.autoPlayInterval = autoPlayInterval
        self.playSignal = playSignal
        self.onPlayCompleted = onPlayCompleted
        self.onAnimationStart = onAnimationStart
    }

    var body: some View {
        mascotView
            .frame(maxWidth: .infinity, alignment: .leading)
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
        onAnimationStart?()
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
private extension MascotView {
    var mascotSize: CGFloat { layoutMetrics.adaptive(120) }

    var staticMascotAssetName: String {
        if colorScheme == .dark, UIImage(named: "\(assetBaseName)Dark") != nil {
            return "\(assetBaseName)Dark"
        }
        return assetBaseName
    }

    var gifMascotAssetName: String {
        if colorScheme == .dark, gifExists(named: "\(assetBaseName)Dark") {
            return "\(assetBaseName)Dark"
        }
        return assetBaseName
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
}

// MARK: - Resource Helpers
private extension MascotView {
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
    MascotView()
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
        .frame(height: 120)
}
