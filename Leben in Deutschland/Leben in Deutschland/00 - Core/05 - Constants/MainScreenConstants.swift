import SwiftUI

// MARK: - Layout Metrics
struct LayoutMetrics {
    static let referenceScreenHeight: CGFloat = 844
    static let referenceScreenWidth: CGFloat = 390
    static let minimumScale: CGFloat = 0.82
    
    static let buttonTapAnimationDuration: Double = 0.22
    static let gifAnimationDuration: Double = 1.1
    static let totalFederalQuestions: Int = 310
    
    let scale: CGFloat
    let screenSize: CGSize
    
    static func make(for size: CGSize) -> LayoutMetrics {
        let heightFactor = size.height / referenceScreenHeight
        let clamped = min(1.0, max(minimumScale, heightFactor))
        return LayoutMetrics(scale: clamped, screenSize: size)
    }
    
    func adaptive(_ base: CGFloat) -> CGFloat {
        base * scale
    }
    
    var screenWidth: CGFloat { screenSize.width }
    var screenHeight: CGFloat { screenSize.height }
}

// MARK: - Environment Support
private struct LayoutMetricsKey: EnvironmentKey {
    static let defaultValue = LayoutMetrics(scale: 1.0, screenSize: .zero)
}

extension EnvironmentValues {
    var layoutMetrics: LayoutMetrics {
        get { self[LayoutMetricsKey.self] }
        set { self[LayoutMetricsKey.self] = newValue }
    }
}

extension View {
    func layoutMetrics(_ metrics: LayoutMetrics) -> some View {
        environment(\.layoutMetrics, metrics)
    }
    
    func layoutMetrics(size: CGSize) -> some View {
        layoutMetrics(LayoutMetrics.make(for: size))
    }
}
