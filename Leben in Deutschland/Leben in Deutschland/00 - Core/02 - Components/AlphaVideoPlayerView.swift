//
//  AlphaVideoPlayerView.swift
//  Leben in Deutschland
//
//  UIViewRepresentable for transparent (alpha) video playback via AVPlayerLayer.
//

import AVFoundation
import SwiftUI
import UIKit

// MARK: - Player container (private to this file)

final class PlayerContainerView: UIView {
    override static var layerClass: AnyClass { AVPlayerLayer.self }
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

// MARK: - SwiftUI bridge

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
