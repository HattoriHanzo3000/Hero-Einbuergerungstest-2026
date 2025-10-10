import SwiftUI
import AVFoundation

struct OnboardingStartView: View {
    @State private var player: AVPlayer?
    @State private var endObserver: NSObjectProtocol?
    @State private var didAdvance: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Background color
            Color.accentColor
                .ignoresSafeArea(.all)
            
            // Video player or loading state
            if let player = player {
                AlphaVideoPlayerView(player: player, videoGravity: .resizeAspect)
                    .ignoresSafeArea(.all)
                    .clipped()
                    .onAppear {
                        player.play()
                    }
            } else {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading...")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                }
            }
        }
        .onAppear {
            setupAudioSession()
            setupVideo()
            // Fallback: auto-advance even if video failed to finish rendering
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                if !didAdvance {
                    didAdvance = true
                    onComplete()
                }
            }
        }
        .onDisappear {
            cleanupPlayback()
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Keep AV pipeline quiet when app is not active
            switch newPhase {
            case .active:
                break
            case .inactive, .background:
                player?.pause()
            @unknown default:
                player?.pause()
            }
        }
    }
    
    // MARK: - Audio Setup
    private func setupAudioSession() {
        do {
            // Configure to allow playback even with Silent switch if desired
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // AVAudioSession configuration failed - continue silently
        }
    }
    
    // MARK: - Video Setup
    private func setupVideo() {
        // Find video file with multiple extension support
        let possibleExtensions = ["mov", "mp4"]
        var videoURL: URL?
        for ext in possibleExtensions {
            if let url = Bundle.main.url(forResource: "start_animation", withExtension: ext) {
                videoURL = url
                break
            }
        }
        
        guard let resolvedURL = videoURL else {
            // Video file not found - fallback to completion
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onComplete()
            }
            return
        }
        
        let playerItem = AVPlayerItem(url: resolvedURL)
        
        // Async video loading
        Task { @MainActor in
            do {
                _ = try await playerItem.asset.load(.tracks)
            } catch {
                // Video track loading failed - continue with playback
            }
            
            let player = AVPlayer(playerItem: playerItem)
            player.actionAtItemEnd = .pause
            
            // Configure sound based on user settings
            let soundEnabled = UserDefaults.standard.object(forKey: "sound_enabled") as? Bool ?? true
            player.isMuted = !soundEnabled
            
            self.player = player
            setupVideoCompletion(for: player)
            player.play()
        }
    }
    
    // MARK: - Video Completion Handler
    private func setupVideoCompletion(for player: AVPlayer) {
        // Remove previous observer if any
        if let token = endObserver {
            NotificationCenter.default.removeObserver(token)
            endObserver = nil
        }
        
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [onComplete] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !didAdvance {
                    didAdvance = true
                    onComplete()
                }
            }
        }
    }
    
    private func cleanupPlayback() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        
        if let token = endObserver {
            NotificationCenter.default.removeObserver(token)
            endObserver = nil
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            // Non-fatal; OK to ignore in most cases
        }
    }
}

// MARK: - Video Player Components
final class PlayerContainerView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}

struct AlphaVideoPlayerView: UIViewRepresentable {
    let player: AVPlayer
    let videoGravity: AVLayerVideoGravity
    
    init(player: AVPlayer, videoGravity: AVLayerVideoGravity = .resizeAspect) {
        self.player = player
        self.videoGravity = videoGravity
    }
    
    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        view.backgroundColor = .clear
        view.isOpaque = false
        let layer = view.playerLayer
        layer.player = player
        layer.isOpaque = false
        layer.backgroundColor = UIColor.clear.cgColor
        layer.videoGravity = videoGravity
        return view
    }
    
    func updateUIView(_ uiView: PlayerContainerView, context: Context) {
        uiView.playerLayer.player = player
        uiView.playerLayer.videoGravity = videoGravity
    }
}

#Preview {
    OnboardingStartView {
        print("Start animation completed")
    }
}
