import SwiftUI
import AVFoundation
import os.log

private let logger = Logger(subsystem: "com.gizatech.LebenInDeutschland", category: "WelcomeVideoView")

struct WelcomeVideoView: View {
    let onComplete: () -> Void

    @State private var player: AVPlayer?
    @State private var endObserver: NSObjectProtocol?
    @State private var timeoutTask: Task<Void, Never>?
    @State private var didComplete = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            if let player {
                AlphaVideoPlayerView(player: player, videoGravity: .resizeAspectFill)
                    .ignoresSafeArea()
                    .onAppear {
                        player.play()
                    }
            } else {
                ProgressView()
                    .scaleEffect(1.4)
            }
        }
        .onAppear {
            setupVideo()
            startTimeout()
        }
        .onDisappear {
            cleanup()
        }
    }

    private func setupVideo() {
        guard let url = VideoBundleLookup.url(forResourceName: "lid_welcome_video", extension: "mp4")
            ?? Bundle.main.url(forResource: "lid_welcome_video", withExtension: "mp4") else {
            logger.error("Welcome video not found, skipping to onboarding")
            complete()
            return
        }

        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)
        player.isMuted = false
        player.actionAtItemEnd = .pause

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: playerItem,
            queue: .main
        ) { _ in
            complete()
        }

        self.player = player
        player.play()
    }

    private func startTimeout() {
        timeoutTask = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: 12_000_000_000)
                if !didComplete {
                    logger.warning("Welcome video timeout reached, continuing to onboarding")
                    complete()
                }
            } catch {
                // Cancellation is expected during normal cleanup.
            }
        }
    }

    private func cleanup() {
        timeoutTask?.cancel()
        timeoutTask = nil

        if let token = endObserver {
            NotificationCenter.default.removeObserver(token)
            endObserver = nil
        }

        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
    }

    private func complete() {
        guard !didComplete else { return }
        didComplete = true
        cleanup()
        onComplete()
    }
}

#Preview {
    WelcomeVideoView {
        print("Welcome completed")
    }
}
