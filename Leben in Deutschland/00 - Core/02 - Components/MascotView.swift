import AVFoundation
import Combine
import SwiftUI
import UIKit

// MARK: - Mascot View
/// Header mascot: static `MascotLiDHeader` + `MascotLidHeaderAnimationLight` / `MascotLidHeaderAnimationDark` videos.
/// Static art stays visible until the video player is ready, so loading never shows an empty space.
struct MascotView {
    /// When `true`, applies horizontal mirroring to match Home / Progress layout (B2: `scaleEffect(x: -1, y: 1)` on the full stack).
    var horizontalMirror: Bool
    var autoPlayInterval: TimeInterval?
    var playSignal: UUID?
    var onPlayCompleted: (() -> Void)?
    /// Called when animation starts (tap, auto-play, or external `playSignal`).
    var onAnimationStart: (() -> Void)?

    init(
        horizontalMirror: Bool = false,
        autoPlayInterval: TimeInterval? = nil,
        playSignal: UUID? = nil,
        onPlayCompleted: (() -> Void)? = nil,
        onAnimationStart: (() -> Void)? = nil
    ) {
        self.horizontalMirror = horizontalMirror
        self.autoPlayInterval = autoPlayInterval
        self.playSignal = playSignal
        self.onPlayCompleted = onPlayCompleted
        self.onAnimationStart = onAnimationStart
    }
}

extension MascotView: View {
    var body: some View {
        MascotViewContent(
            horizontalMirror: horizontalMirror,
            autoPlayInterval: autoPlayInterval,
            playSignal: playSignal,
            onPlayCompleted: onPlayCompleted,
            onAnimationStart: onAnimationStart
        )
    }
}

// MARK: - Content (separate type to hold @State; keeps Equatable / identity stable for previews)
private struct MascotViewContent: View {
    var horizontalMirror: Bool
    var autoPlayInterval: TimeInterval?
    var playSignal: UUID?
    var onPlayCompleted: (() -> Void)?
    var onAnimationStart: (() -> Void)?

    @State private var mascotPlaybackActive = false
    @State private var mascotGifEndWorkItem: DispatchWorkItem?
    @State private var autoPlayTask: Task<Void, Never>?
    @State private var playbackDurationTask: Task<Void, Never>?
    @State private var mascotPlayer: AVPlayer?
    @State private var playerAssetName: String?
    @State private var mascotVideoReadyForDisplay = false
    @State private var videoReadyObserver: AnyCancellable?
    @State private var resolvedPlaybackDuration: TimeInterval = 1.0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.layoutMetrics) private var layoutMetrics

    private var mascotSize: CGFloat { layoutMetrics.adaptive(120) }

    private var staticMascotAssetName: String { "MascotLiDHeader" }

    private var videoMascotAssetName: String {
        colorScheme == .dark ? "MascotLidHeaderAnimationDark" : "MascotLidHeaderAnimationLight"
    }

    private var hasVideoAsset: Bool {
        VideoBundleLookup.resourceExists(resourceName: videoMascotAssetName)
    }

    private var mascotPlaybackDuration: TimeInterval { resolvedPlaybackDuration }

    var body: some View {
        mascotStack
            .frame(width: mascotSize, height: mascotSize)
            .scaleEffect(x: horizontalMirror ? -1 : 1, y: 1)
            .contentShape(Rectangle())
            .onTapGesture {
                HapticManager.shared.lightImpact()
                if reduceMotion {
                    onPlayCompleted?()
                } else {
                    playAnimationOnly(completion: nil)
                }
            }
            .onChange(of: playSignal) { _, _ in
                if reduceMotion {
                    onPlayCompleted?()
                } else {
                    playAnimationOnly(completion: onPlayCompleted)
                }
            }
            .onAppear {
                preparePlayerIfNeeded()
                refreshPlaybackDuration()
                if let interval = autoPlayInterval, !reduceMotion {
                    startAutoPlay(interval: interval)
                }
            }
            .onChange(of: colorScheme) { _, _ in
                preparePlayerIfNeeded()
                refreshPlaybackDuration()
            }
            .onDisappear {
                autoPlayTask?.cancel()
                autoPlayTask = nil
                playbackDurationTask?.cancel()
                playbackDurationTask = nil
                mascotGifEndWorkItem?.cancel()
                mascotGifEndWorkItem = nil
                videoReadyObserver?.cancel()
                videoReadyObserver = nil
                mascotPlayer?.pause()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var mascotStack: some View {
        ZStack {
            Image(staticMascotAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: mascotSize, height: mascotSize)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                .accessibilityLabel("Mascot")
                .opacity((hasVideoAsset && !reduceMotion && mascotVideoReadyForDisplay) ? 0 : 1)
                .allowsHitTesting(false)

            if hasVideoAsset, !reduceMotion, let mascotPlayer {
                AlphaVideoPlayerView(player: mascotPlayer, videoGravity: .resizeAspect)
                    .id(videoMascotAssetName)
                    .frame(width: mascotSize, height: mascotSize)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .accessibilityLabel("Mascot")
                    .opacity(mascotVideoReadyForDisplay ? 1 : 0)
                    .allowsHitTesting(false)
            }
        }
    }

    private func refreshPlaybackDuration() {
        playbackDurationTask?.cancel()
        playbackDurationTask = Task {
            let duration = await VideoBundleLookup.duration(forResourceName: videoMascotAssetName) ?? 1.0
            await MainActor.run {
                resolvedPlaybackDuration = duration
            }
        }
    }

    private func preparePlayerIfNeeded() {
        guard !reduceMotion else {
            videoReadyObserver?.cancel()
            videoReadyObserver = nil
            mascotVideoReadyForDisplay = false
            mascotPlayer?.pause()
            mascotPlayer = nil
            playerAssetName = nil
            return
        }
        guard hasVideoAsset else {
            videoReadyObserver?.cancel()
            videoReadyObserver = nil
            mascotVideoReadyForDisplay = false
            mascotPlayer?.pause()
            mascotPlayer = nil
            playerAssetName = nil
            return
        }
        if playerAssetName == videoMascotAssetName, mascotPlayer != nil { return }
        guard let url = VideoBundleLookup.url(forResourceName: videoMascotAssetName) else { return }

        videoReadyObserver?.cancel()
        videoReadyObserver = nil
        mascotVideoReadyForDisplay = false

        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)
        player.actionAtItemEnd = .pause
        player.isMuted = true
        mascotPlayer = player
        playerAssetName = videoMascotAssetName
        player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        observeVideoReadiness(playerItem: playerItem)
    }

    private func observeVideoReadiness(playerItem: AVPlayerItem) {
        if playerItem.status == .readyToPlay {
            mascotVideoReadyForDisplay = true
            return
        }
        videoReadyObserver = playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { status in
                guard status == .readyToPlay else { return }
                mascotVideoReadyForDisplay = true
            }
    }

    private func playAnimationOnly(completion: (() -> Void)?) {
        guard !reduceMotion else { return }
        guard !mascotPlaybackActive else { return }

        mascotGifEndWorkItem?.cancel()

        onAnimationStart?()

        mascotPlaybackActive = true
        if hasVideoAsset {
            preparePlayerIfNeeded()
            mascotPlayer?.seek(to: .zero)
            mascotPlayer?.play()
        } else {
            // No GIF fallback: if video is missing, keep static mascot and complete safely.
            mascotPlaybackActive = false
            completion?()
            return
        }

        let work = DispatchWorkItem {
            mascotPlaybackActive = false
            mascotGifEndWorkItem = nil
            mascotPlayer?.pause()
            mascotPlayer?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
            completion?()
        }
        mascotGifEndWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + mascotPlaybackDuration, execute: work)
    }

    private func startAutoPlay(interval: TimeInterval) {
        autoPlayTask?.cancel()
        autoPlayTask = Task { [reduceMotion] in
            guard !reduceMotion else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                if Task.isCancelled { break }
                await MainActor.run {
                    playAnimationOnly(completion: nil)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MascotView()
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
        .frame(height: 120)
}
