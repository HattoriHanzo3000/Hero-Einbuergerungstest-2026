//
//  QuestionNavigationBar.swift
//  Leben in Deutschland
//
//  Shared horizontal nav row: back arrow + scrollable numbered circles + forward arrow.
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
    
    /// Arrow button size. Default 34; Learning uses 42.
    var arrowCircleSize: CGFloat? = nil
    /// Numbered circle size. Default 34.
    var numberedCircleSize: CGFloat? = nil
    /// Haptic on scroll drag. Test/Favorites use this.
    var enableScrollHaptic: Bool = false
    /// Haptic on index change. Test/Favorites use this.
    var enableChangeHaptic: Bool = false
    
    @Environment(\.layoutMetrics) private var layoutMetrics
    @State private var lastScrollHapticTs: Double = 0
    
    private var resolvedNumberedSize: CGFloat {
        numberedCircleSize ?? layoutMetrics.adaptive(34)
    }
    
    private var resolvedArrowSize: CGFloat {
        arrowCircleSize ?? resolvedNumberedSize
    }
    
    private var rowHeight: CGFloat {
        resolvedArrowSize + layoutMetrics.adaptive(LayoutMetrics.footerNavigationBarRowExtraHeight)
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            HStack(spacing: layoutMetrics.adaptive(12)) {
                backButton
                circlesZStack(proxy: proxy)
                forwardButton
            }
            .padding(.horizontal, layoutMetrics.adaptive(LayoutMetrics.footerHorizontalPadding))
            .frame(height: rowHeight)
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
    
    private var backButton: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            onPrevious()
        }) {
            Image(systemName: "chevron.backward")
                .font(.system(size: arrowFontSize, weight: .semibold))
                .foregroundColor(currentIndex > 0 ? .white : Color.white.opacity(0.5))
                .frame(width: resolvedArrowSize, height: resolvedArrowSize)
                .background(Circle().fill(Color("AppBlueLagoon")))
        }
        .disabled(currentIndex <= 0)
        .buttonStyle(.plain)
        .accessibilityLabel("Previous question")
        .accessibilityHint("Go to previous question")
    }
    
    private var arrowFontSize: CGFloat {
        resolvedArrowSize > resolvedNumberedSize
            ? layoutMetrics.adaptive(18)
            : layoutMetrics.adaptive(16)
    }
    
    private func circlesZStack(proxy: ScrollViewProxy) -> some View {
        ZStack(alignment: .center) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 12) {
                    ForEach(0..<questionCount, id: \.self) { index in
                        let isActive = index == currentIndex
                        let circleSize = isActive ? resolvedArrowSize : resolvedNumberedSize
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            onSelectIndex(index)
                        }) {
                            Circle()
                                .fill(circleColor(index))
                                .frame(width: circleSize, height: circleSize)
                                .overlay(
                                    Text("\(index + 1)")
                                        .font(.system(size: layoutMetrics.adaptive(isActive ? 16 : 14), weight: .semibold))
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
    
    private var forwardButton: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            onNext()
        }) {
            Image(systemName: "chevron.forward")
                .font(.system(size: arrowFontSize, weight: .semibold))
                .foregroundColor(currentIndex < questionCount - 1 ? .white : Color.white.opacity(0.5))
                .frame(width: resolvedArrowSize, height: resolvedArrowSize)
                .background(Circle().fill(Color("AppBlueLagoon")))
        }
        .disabled(currentIndex >= questionCount - 1)
        .buttonStyle(.plain)
        .accessibilityLabel("Next question")
        .accessibilityHint("Go to next question")
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
        onPrevious: {},
        onNext: {},
        onSelectIndex: { _ in }
    )
    .layoutMetrics(size: CGSize(width: 390, height: 844))
}
