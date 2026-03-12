//
//  QuestionNavigationBar.swift
//  Leben in Deutschland
//
//  Horizontal scroll of numbered circles only (no back/forward arrows).
//  Used by LearningView, TestSessionQuestionCard, TestAnswersView, FavoritesQuestionCard.
//

import SwiftUI

// MARK: - Question Navigation Bar
struct QuestionNavigationBar: View {
    let questionCount: Int
    let currentIndex: Int
    let circleColor: (Int) -> Color
    var circleTextColor: (Int) -> Color = { _ in .white }
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onSelectIndex: (Int) -> Void

    /// When set, back/forward arrows use this gradient (matches header).
    var gradient: LiquidGlassGradient? = nil
    /// When gradient is set, which circles use it. Default: circles where circleColor != gray.
    var circleUsesGradient: ((Int) -> Bool)? = nil
    /// Per-circle gradient (e.g. .green correct, .red wrong). When non-nil, overrides gradient for that circle.
    var circleGradient: ((Int) -> LiquidGlassGradient?)? = nil
    
    /// Arrow button size. Default 38; callers use 46 for active circle.
    var arrowCircleSize: CGFloat? = nil
    /// Numbered circle size. Default 38 (bumped for 3-digit numbers).
    var numberedCircleSize: CGFloat? = nil
    /// Haptic on scroll drag. Test/Favorites use this.
    var enableScrollHaptic: Bool = false
    /// Haptic on index change. Test/Favorites use this.
    var enableChangeHaptic: Bool = false
    
    @Environment(\.layoutMetrics) private var layoutMetrics
    @State private var lastScrollHapticTs: Double = 0
    
    private var resolvedNumberedSize: CGFloat {
        numberedCircleSize ?? layoutMetrics.adaptive(38)
    }
    
    private var resolvedArrowSize: CGFloat {
        arrowCircleSize ?? resolvedNumberedSize
    }
    
    private var rowHeight: CGFloat {
        resolvedArrowSize + layoutMetrics.adaptive(LayoutMetrics.footerNavigationBarRowExtraHeight)
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            circlesZStack(proxy: proxy)
                .padding(.horizontal, layoutMetrics.adaptive(LayoutMetrics.footerHorizontalPadding))
                .frame(height: rowHeight)
                .onAppear {
                    proxy.scrollTo(currentIndex, anchor: .center)
                }
                .onChange(of: currentIndex) { _, newIndex in
                    withAnimation {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                    if enableChangeHaptic {
                        HapticManager.shared.lightImpact()
                    }
                }
        }
    }

    private func circlesZStack(proxy: ScrollViewProxy) -> some View {
        ZStack(alignment: .center) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 12) {
                    ForEach(0..<questionCount, id: \.self) { index in
                        let isActive = index == currentIndex
                        let circleSize = isActive ? resolvedArrowSize : resolvedNumberedSize
                        let usesGradient = gradient != nil && (circleUsesGradient?(index) ?? (circleColor(index) != Color(.systemGray5)))
                        let fillStyle: AnyShapeStyle = if let perCircle = circleGradient?(index) {
                            AnyShapeStyle(perCircle.screenBackground)
                        } else if let g = gradient, usesGradient {
                            AnyShapeStyle(g.screenBackground)
                        } else {
                            AnyShapeStyle(circleColor(index))
                        }
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            onSelectIndex(index)
                        }) {
                            Circle()
                                .fill(fillStyle)
                                .frame(width: circleSize, height: circleSize)
                                .overlay(
                                    Text("\(index + 1)")
                                        .font(
                                            .system(size: layoutMetrics.adaptive(isActive ? 15 : 13), weight: .semibold)
                                                .width(.expanded)
                                        )
                                        .foregroundColor(circleTextColor(index))
                                )
                        }
                        .id(index)
                    }
                }
                .frame(minHeight: rowHeight)
                .padding(.horizontal, 0)
            }
            .modifier(ScrollHapticModifier(enabled: enableScrollHaptic, lastTs: $lastScrollHapticTs))
            
            HStack {
                verticalSeparator
                Spacer(minLength: 0)
                verticalSeparator
            }
            .frame(height: resolvedNumberedSize)
            .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity)
    }

    private var verticalSeparator: some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(width: 1)
            .frame(height: resolvedNumberedSize)
    }
}

// MARK: - Scroll Haptic Modifier
private struct ScrollHapticModifier: ViewModifier {
    let enabled: Bool
    @Binding var lastTs: Double
    
    func body(content: Content) -> some View {
        if enabled {
            content.simultaneousGesture(DragGesture().onChanged { _ in
                let now = Date().timeIntervalSince1970
                if now - lastTs > 0.2 {
                    lastTs = now
                    HapticManager.shared.lightImpact()
                }
            })
        } else {
            content
        }
    }
}

// MARK: - Preview
#Preview("Question Navigation Bar") {
    QuestionNavigationBar(
        questionCount: 10,
        currentIndex: 2,
        circleColor: { $0 == 2 ? Color("AppBlueLagoon") : Color(.systemGray5) },
        circleTextColor: { _ in .white },
        onPrevious: {},
        onNext: {},
        onSelectIndex: { _ in },
        gradient: .blue
    )
    .layoutMetrics(size: CGSize(width: 390, height: 844))
}
