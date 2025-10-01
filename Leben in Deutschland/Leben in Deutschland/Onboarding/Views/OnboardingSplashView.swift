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
                        setupVideoCompletion()
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
            print("❌ AVAudioSession error: \(error)")
        }
    }
    
    private func setupVideo() {
        guard let url = Bundle.main.url(forResource: "splash_animation", withExtension: "mp4") else {
            print("❌ Could not find splash_animation.mp4 in bundle")
            // Fallback: complete onboarding after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                completeOnboarding()
            }
            return
        }
        
        let item = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: item)
        self.player?.actionAtItemEnd = .pause
        
        // Respect sound setting (default to enabled if not set)
        let soundEnabled = UserDefaults.standard.object(forKey: "sound_enabled") as? Bool ?? true
        self.player?.isMuted = !soundEnabled
    }
    
    private func setupVideoCompletion() {
        guard let player = player else { return }
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            completeOnboarding()
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
