import SwiftUI
import AVFoundation

// MARK: - Onboarding Splash View
struct OnboardingSplashView: View {
    @State private var player: AVPlayer?
    @State private var isVideoFinished = false
    let onFinish: () -> Void
    
    var body: some View {
        ZStack {
            // Background color matching the old project
            Color(red: 134/255, green: 197/255, blue: 255/255)
                .ignoresSafeArea()
            
            if let player = player {
                AlphaVideoPlayerView(player: player, videoGravity: .resizeAspect)
                    .ignoresSafeArea()
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else {
                // Loading state
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
        }
        .onAppear {
            setupAudioSession()
            setupVideo()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // AVAudioSession configuration failed - continue silently
        }
    }
    
    private func setupVideo() {
        // Find video file with multiple extension support
        let possibleExtensions = ["mov", "mp4"]
        var videoURL: URL?
        for ext in possibleExtensions {
            if let url = Bundle.main.url(forResource: "splash_animation", withExtension: ext) {
                videoURL = url
                break
            }
        }
        
        guard let resolvedURL = videoURL else {
            // Video file not found - fallback to completion
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                completeOnboarding()
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
    
    private func setupVideoCompletion(for player: AVPlayer) {
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completeOnboarding()
            }
        }
    }
    
    private func completeOnboarding() {
        // Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Navigate to main app after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onFinish()
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingSplashView(onFinish: {})
}
