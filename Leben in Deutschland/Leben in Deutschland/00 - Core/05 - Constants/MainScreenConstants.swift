import SwiftUI

// MARK: - Layout Metrics
struct LayoutMetrics {
    static let referenceScreenHeight: CGFloat = 844
    static let referenceScreenWidth: CGFloat = 390
    static let minimumScale: CGFloat = 0.82
    
    // MARK: - Screen Layout
    static let headerHorizontalPadding: CGFloat = 20
    static let headerTopPadding: CGFloat = 8
    static let headerBottomPadding: CGFloat = 4
    static let sectionSpacing: CGFloat = 28
    static let footerPadding: CGFloat = 36
    
    static let buttonTapAnimationDuration: Double = 0.22
    static let gifAnimationDuration: Double = 1.1
    static let totalFederalQuestions: Int = 310
    
    // MARK: - Spaced Repetition
    static let maxHorizonDays: Int = 30
    static let targetCorrectPerQuestion: Int = 4
    static let totalSpacedRepetitionQuestions: Int = 320
    
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
    
    /// Standard padding for screen headers (used by Home, Progress, etc.).
    func screenHeaderPadding(metrics: LayoutMetrics) -> some View {
        self
            .padding(.horizontal, metrics.adaptive(LayoutMetrics.headerHorizontalPadding))
            .padding(.top, metrics.adaptive(LayoutMetrics.headerTopPadding))
            .padding(.bottom, metrics.adaptive(LayoutMetrics.headerBottomPadding))
    }
}
