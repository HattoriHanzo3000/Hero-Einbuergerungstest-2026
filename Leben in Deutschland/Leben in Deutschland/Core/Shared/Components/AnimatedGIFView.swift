import SwiftUI
import UIKit
import ImageIO

// MARK: - Animated GIF View
struct AnimatedGIFView: UIViewRepresentable {
    let gifName: String
    let contentMode: UIView.ContentMode

    init(gifName: String, contentMode: UIView.ContentMode = .scaleAspectFit) {
        self.gifName = gifName
        self.contentMode = contentMode
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
        
        // Configure as frame-based animation to allow one-shot playback
        if let config = loadAnimationConfig() {
            imageView.animationImages = config.images
            imageView.animationDuration = config.duration
            imageView.animationRepeatCount = 1
            imageView.image = config.images.first
            DispatchQueue.main.async {
                imageView.startAnimating()
            }
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

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let imageView = uiView.subviews.compactMap({ $0 as? UIImageView }).first {
            imageView.contentMode = contentMode
            if let config = loadAnimationConfig() {
                imageView.stopAnimating()
                imageView.animationImages = config.images
                imageView.animationDuration = config.duration
                imageView.animationRepeatCount = 1
                imageView.image = config.images.first
                DispatchQueue.main.async {
                    imageView.startAnimating()
                }
            } else {
                imageView.image = loadAnimatedImageFallback()
            }
        }
    }

    private func loadAnimatedImageFallback() -> UIImage? {
        guard let url = Bundle.main.url(forResource: gifName, withExtension: "gif") else {
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

    private func loadAnimationConfig() -> (images: [UIImage], duration: Double)? {
        guard let url = Bundle.main.url(forResource: gifName, withExtension: "gif") else {
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
