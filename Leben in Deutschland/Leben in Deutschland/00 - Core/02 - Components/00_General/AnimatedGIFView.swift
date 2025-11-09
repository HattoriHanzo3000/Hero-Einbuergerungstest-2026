import SwiftUI
import UIKit
import ImageIO

// MARK: - Animated GIF View
struct AnimatedGIFView: UIViewRepresentable {
    let gifName: String
    let contentMode: UIView.ContentMode
    let shouldAnimate: Bool

    init(gifName: String, contentMode: UIView.ContentMode = .scaleAspectFit, shouldAnimate: Bool = true) {
        self.gifName = gifName
        self.contentMode = contentMode
        self.shouldAnimate = shouldAnimate
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = contentMode
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // Store imageView in coordinator
        context.coordinator.imageView = imageView
        
        // Prefer animated UIImage path (more reliable on some iOS versions)
        if let animated = loadAnimatedUIImage() {
            imageView.animationImages = nil
            imageView.image = animated.image
            context.coordinator.animationConfig = (animated.frames, animated.duration)
#if DEBUG
            print("[AnimatedGIFView] Loaded animated UIImage with \(animated.frames.count) frames, duration: \(animated.duration)")
#endif
        } else if let config = loadAnimationConfig() {
            imageView.animationImages = config.images
            imageView.animationDuration = config.duration
            imageView.animationRepeatCount = 1
            imageView.image = config.images.first
            context.coordinator.animationConfig = config
#if DEBUG
            print("[AnimatedGIFView] Loaded frames: \(config.images.count), duration: \(config.duration)")
#endif
        } else {
            imageView.image = loadAnimatedImageFallback()
        }

        container.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        // Start animation if shouldAnimate is true (ensure layout first)
        if shouldAnimate {
            DispatchQueue.main.async {
                imageView.startAnimating()
            }
        }

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let imageView = context.coordinator.imageView else { return }
        
        imageView.contentMode = contentMode
        
        // Restart animation when shouldAnimate changes to true
        if shouldAnimate {
            // Check if animation is already running by checking if animationImages is set
            if imageView.animationImages == nil || imageView.animationImages?.isEmpty == true {
                // Try animated UIImage first
                if let animated = loadAnimatedUIImage() {
                    imageView.animationImages = nil
                    imageView.image = animated.image
                    context.coordinator.animationConfig = (animated.frames, animated.duration)
                } else {
                    // Ensure we have an animation config; reload if missing
                    if context.coordinator.animationConfig == nil {
                        context.coordinator.animationConfig = loadAnimationConfig()
                    }
                    if let config = context.coordinator.animationConfig {
                        imageView.animationImages = config.images
                        imageView.animationDuration = config.duration
                        imageView.animationRepeatCount = 1
                        imageView.image = config.images.first
                    } else {
                        // Last resort: static first frame
                        imageView.animationImages = nil
                        imageView.image = loadAnimatedImageFallback()
                    }
                }
            }
            // Start animation if not already running
            if imageView.animationImages != nil && !imageView.animationImages!.isEmpty {
                imageView.stopAnimating() // Stop any existing animation
                DispatchQueue.main.async {
                    imageView.startAnimating()
                }
            } else if let animated = imageView.image, animated.images != nil {
                // Animated UIImage fallback
                imageView.stopAnimating()
                DispatchQueue.main.async {
                    imageView.startAnimating()
                }
            } else {
                // Last resort: CAKeyframeAnimation over layer.contents
                if let config = loadAnimationConfig() {
                    let images = config.images
                    let duration = max(config.duration, 0.1)
                    let contents = images.compactMap { $0.cgImage }
                    if !contents.isEmpty {
                        let animation = CAKeyframeAnimation(keyPath: "contents")
                        animation.values = contents
                        // Evenly spaced if we don't have per-frame timing here
                        let count = contents.count
                        animation.keyTimes = (0..<count).map { NSNumber(value: Double($0) / Double(max(count - 1, 1))) }
                        animation.duration = duration
                        animation.calculationMode = .discrete
                        animation.repeatCount = 0
                        animation.isRemovedOnCompletion = true
                        DispatchQueue.main.async {
                            imageView.layer.add(animation, forKey: "gif_keyframe_animation")
                        }
                    }
                }
            }
        } else {
            // Stop animation when shouldAnimate is false
            imageView.stopAnimating()
            imageView.layer.removeAnimation(forKey: "gif_keyframe_animation")
        }
    }
    
    // MARK: - Coordinator
    class Coordinator {
        var imageView: UIImageView?
        var animationConfig: (images: [UIImage], duration: Double)?
    }

    private func loadAnimatedImageFallback() -> UIImage? {
        guard let url = resolveGifURL() else {
            return nil
        }
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let frameCount = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var totalDuration: Double = 0

        for index in 0..<frameCount {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) {
                let frameDuration = AnimatedGIFView.frameDuration(at: index, source: source)
                totalDuration += frameDuration
                images.append(UIImage(cgImage: cgImage))
            }
        }

        if images.isEmpty { return nil }
        if totalDuration <= 0 { totalDuration = Double(images.count) * (1.0 / 24.0) }
        return UIImage.animatedImage(with: images, duration: totalDuration)
    }

    // Return animated UIImage plus frames and duration for control
    private func loadAnimatedUIImage() -> (image: UIImage, frames: [UIImage], duration: Double)? {
        guard let url = resolveGifURL() else { return nil }
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let frameCount = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var totalDuration: Double = 0
        for index in 0..<frameCount {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) {
                let frameDuration = AnimatedGIFView.frameDuration(at: index, source: source)
                totalDuration += frameDuration
                images.append(UIImage(cgImage: cgImage))
            }
        }
        if images.isEmpty { return nil }
        if totalDuration <= 0 { totalDuration = Double(images.count) * (1.0 / 24.0) }
        guard let animated = UIImage.animatedImage(with: images, duration: totalDuration) else { return nil }
        return (animated, images, totalDuration)
    }

    private func loadAnimationConfig() -> (images: [UIImage], duration: Double)? {
        guard let url = resolveGifURL() else {
            return nil
        }
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let frameCount = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var totalDuration: Double = 0

        for index in 0..<frameCount {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, index, nil) {
                let frameDuration = AnimatedGIFView.frameDuration(at: index, source: source)
                totalDuration += frameDuration
                images.append(UIImage(cgImage: cgImage))
            }
        }
        if images.isEmpty { return nil }
        if totalDuration <= 0 { totalDuration = Double(images.count) * (1.0 / 24.0) }
        return (images, totalDuration)
    }

    // Try multiple bundle locations to support folder references like "Resources/GIFs"
    private func resolveGifURL() -> URL? {
        // Try name and a dark/light fallback candidate if applicable
        let baseName: String
        let candidates: [String]
        if gifName.hasSuffix("Dark") {
            baseName = String(gifName.dropLast(4))
            candidates = [gifName, baseName]
        } else {
            baseName = gifName
            candidates = [gifName]
        }

        let subdirs = [nil, "Resources/GIFs", "GIFs"]
        for name in candidates {
            for sub in subdirs {
                if let url = Bundle.main.url(forResource: name, withExtension: "gif", subdirectory: sub) {
#if DEBUG
                    print("[AnimatedGIFView] Resolved GIF URL: \(url.path)")
#endif
                    return url
                }
            }
        }
#if DEBUG
        print("[AnimatedGIFView] Failed to resolve GIF URL for \(gifName)")
#endif
        return nil
    }

    private static func frameDuration(at index: Int, source: CGImageSource) -> Double {
        var duration = 0.1
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
              let gifProperties = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] else {
            return duration
        }

        if let unclampedDelayTime = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? Double, unclampedDelayTime > 0 {
            duration = unclampedDelayTime
        } else if let delayTime = gifProperties[kCGImagePropertyGIFDelayTime] as? Double, delayTime > 0 {
            duration = delayTime
        }

        // Fallback for very small frame delays
        if duration < 0.02 { duration = 0.1 }
        return duration
    }
}
