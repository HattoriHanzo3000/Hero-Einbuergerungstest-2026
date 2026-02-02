//
//  LearnOptionsCarouselView.swift
//  Leben in Deutschland
//
//  Horizontally scrolling showcase of learning pathways with rich, editorial styling.
//

import SwiftUI

/// Displays the Learn options as a horizontally scrollable, editorial-style carousel.
struct LearnOptionsCarouselView: View {
    let options: [LearnOptionModel]
    let onSelect: (LearnOptionModel) -> Void
    let containerWidth: CGFloat
    let horizontalSafeInset: CGFloat
    let descriptionHorizontalPadding: CGFloat
    
    @Binding var highlightedOptionID: UUID?
    @State private var displayedOptionID: UUID?
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    init(
        options: [LearnOptionModel],
        highlightedOptionID: Binding<UUID?>,
        onSelect: @escaping (LearnOptionModel) -> Void,
        containerWidth: CGFloat,
        horizontalSafeInset: CGFloat,
        descriptionHorizontalPadding: CGFloat = 20
    ) {
        self.options = options
        self._highlightedOptionID = highlightedOptionID
        self.onSelect = onSelect
        self.containerWidth = containerWidth
        self.horizontalSafeInset = horizontalSafeInset
        self.descriptionHorizontalPadding = descriptionHorizontalPadding
    }
    
    // MARK: - Layout Constants
    private var sectionSpacing: CGFloat { layoutMetrics.adaptive(20) }
    private var iconCarouselHeight: CGFloat { layoutMetrics.adaptive(240) }
    private var iconSize: CGFloat { layoutMetrics.adaptive(68) * 1.5 }
    private var descriptionCornerRadius: CGFloat { layoutMetrics.adaptive(28) }
    private var descriptionPadding: CGFloat { layoutMetrics.adaptive(22) }
    
    var body: some View {
        VStack(spacing: sectionSpacing) {
            headerContainer
            
            iconCarousel
            
            LearnOptionDescriptionCardView(
                option: highlightedOption(),
                cornerRadius: descriptionCornerRadius,
                horizontalInset: layoutMetrics.adaptive(descriptionHorizontalPadding),
                contentPadding: descriptionPadding
            )
        }
        .padding(.top, layoutMetrics.adaptive(4))
        .onAppear {
            // Initialize if not set
            if highlightedOptionID == nil {
            highlightedOptionID = options.first?.id
            }
            // Sync displayedOptionID with highlightedOptionID
            if displayedOptionID != highlightedOptionID {
                displayedOptionID = highlightedOptionID ?? options.first?.id
            }
        }
        .onChange(of: highlightedOptionID) { _, newValue in
            guard let newValue else { return }
            updateDisplayed(with: newValue)
        }
    }
}

// MARK: - Helpers
private extension LearnOptionsCarouselView {
    func highlightedOption() -> LearnOptionModel? {
        guard let id = displayedOptionID else { return options.first }
        return options.first { $0.id == id } ?? options.first
    }
    
    var currentIndex: Int {
        guard let option = highlightedOption(),
              let index = options.firstIndex(where: { $0.id == option.id }) else {
            return 0
        }
        return index
    }
    
    func updateHighlight(with id: UUID) {
        guard highlightedOptionID != id else {
            updateDisplayed(with: id)
            return 
        }
        highlightedOptionID = id
    }
    
    func updateDisplayed(with id: UUID) {
        guard displayedOptionID != id else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            displayedOptionID = id
            HapticManager.shared.lightImpact()
        }
    }
    
    func previousOption() -> LearnOptionModel? {
        guard options.count > 1 else { return nil }
        let index = currentIndex - 1
        guard index >= 0 else { return nil }
        return options[index]
    }
    
    func nextOption() -> LearnOptionModel? {
        guard options.count > 1 else { return nil }
        let index = currentIndex + 1
        guard index < options.count else { return nil }
        return options[index]
    }
}

// MARK: - Subviews
private extension LearnOptionsCarouselView {
    var iconCarousel: some View {
        VStack(spacing: sectionSpacing) {
            TabView(selection: $highlightedOptionID) {
                ForEach(options) { option in
                    Button {
                        HapticManager.shared.lightImpact()
                        updateHighlight(with: option.id)
                        onSelect(option)
                    } label: {
                        LearnOptionIconView(
                            option: option,
                            size: iconSize
                        )
                        .frame(width: containerWidth, height: iconCarouselHeight, alignment: .center)
                    }
                    .buttonStyle(.plain)
                    .tag(option.id)
                }
            }
            .frame(height: iconCarouselHeight)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .accessibilityHint("learn_options_scroll_hint".localized)
            .overlay(alignment: .center) {
                ZStack {
                    if let previous = previousOption() {
                        LearnOptionSideHaloView(option: previous, size: iconSize * 1.35)
                            .offset(x: -containerWidth * 0.6)
                    }
                    
                    if let next = nextOption() {
                        LearnOptionSideHaloView(option: next, size: iconSize * 1.35)
                            .offset(x: containerWidth * 0.6)
                    }
                }
                .allowsHitTesting(false)
            }
            
            LearnScrollIndicatorView(
                totalDots: options.count,
                currentIndex: currentIndex,
                activeColor: highlightedOption()?.palette.accentColor ?? Color.accentColor
            )
            .padding(.horizontal, horizontalSafeInset)
        }
    }
    
    var headerContainer: some View {
        let highlightedOption = highlightedOption()
        let title = highlightedOption?.titleKey.localized ?? "learn_options_section_title".localized
        let accentColor = highlightedOption?.palette.accentColor ?? Color.primary
        
        return VStack(spacing: layoutMetrics.adaptive(12)) {
            Text(title)
                .font(.system(.title, design: .rounded).weight(.bold))
                .foregroundColor(accentColor)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, horizontalSafeInset)
                .accessibilityAddTraits(.isHeader)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview("Learn Options Carousel", traits: .sizeThatFitsLayout) {
    struct PreviewWrapper: View {
        @StateObject private var viewModel = LearnOptionsViewModel()

        var body: some View {
            LearnOptionsCarouselView(
        options: viewModel.options,
                highlightedOptionID: $viewModel.highlightedOptionID,
        onSelect: { _ in },
        containerWidth: 360,
        horizontalSafeInset: 24
    )
    .environmentObject(LanguageManager())
    .dynamicTypeSize(.medium ... .accessibility5)
    .environment(\.sizeCategory, .accessibilityExtraLarge)
    .padding(.vertical)
    .background(Color(.systemGroupedBackground))
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
        }
    }
    
    return PreviewWrapper()
}

// MARK: - Learn Option Icon
private struct LearnOptionIconView: View {
    let option: LearnOptionModel
    let size: CGFloat
    
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(option.palette.gradient)
                .opacity(0.35)
                .frame(width: size * 1.35, height: size * 1.35)
                .blur(radius: 24)
            
            Circle()
                .stroke(option.palette.accentColor.opacity(0.22), lineWidth: 2)
                .frame(width: size * 1.25, height: size * 1.25)
                .shadow(color: option.palette.accentColor.opacity(0.25), radius: 16, x: 0, y: 10)
            
            Image(systemName: option.iconSystemName)
                .font(.system(size: size, weight: .semibold))
                .symbolRenderingMode(.palette)
                .foregroundStyle(option.palette.accentColor)
                .accessibilityHidden(true)
                .scaleEffect(pulse ? 1.04 : 0.96)
                .animation(
                    .easeInOut(duration: 1.8)
                        .repeatForever(autoreverses: true),
                    value: pulse
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onAppear {
            pulse = true
        }
    }
}

// MARK: - Scroll Indicator
private struct LearnScrollIndicatorView: View {
    let totalDots: Int
    let currentIndex: Int
    let activeColor: Color
    
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    private var dotSize: CGFloat { layoutMetrics.adaptive(6) }
    private var dotSpacing: CGFloat { layoutMetrics.adaptive(6) }
    
    var body: some View {
        HStack(spacing: dotSpacing) {
            ForEach(0..<totalDots, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? activeColor : Color(.tertiaryLabel).opacity(0.4))
                    .frame(width: dotSize, height: dotSize)
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - Description Card
private struct LearnOptionDescriptionCardView: View {
    let option: LearnOptionModel?
    let cornerRadius: CGFloat
    let horizontalInset: CGFloat
    let contentPadding: CGFloat
    
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    var body: some View {
        Group {
            if let option {
                VStack(spacing: layoutMetrics.adaptive(12)) {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(Color.clear)
                        .frame(height: contentPadding)
                    
                    VStack(alignment: .leading, spacing: layoutMetrics.adaptive(12)) {
                        Text(option.descriptionKey.localized)
                            .font(.system(.body, design: .rounded).weight(.semibold))
                            .foregroundColor(option.palette.accentColor.opacity(0.95))
                            .lineSpacing(4)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityLabel(option.descriptionKey.localized)
                    }
                    .padding(contentPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                            .overlay(
                                option.palette.gradient
                                    .opacity(0.28)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .stroke(option.palette.accentColor.opacity(0.24), lineWidth: 1)
                            )
                            .shadow(color: option.palette.accentColor.opacity(0.14), radius: 20, x: 0, y: 14)
                    )
                }
            } else {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(.secondarySystemBackground).opacity(0.6))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, horizontalInset)
    }
}

// MARK: - Side Halo View
private struct LearnOptionSideHaloView: View {
    let option: LearnOptionModel
    let size: CGFloat
    
    var body: some View {
        Circle()
            .fill(option.palette.gradient)
            .opacity(0.18)
            .frame(width: size, height: size)
            .blur(radius: 26)
    }
}


