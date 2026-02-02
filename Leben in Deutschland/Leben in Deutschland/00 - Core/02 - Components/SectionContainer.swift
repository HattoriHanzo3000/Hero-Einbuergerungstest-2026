import SwiftUI

/// Reusable container for settings/setup sections with consistent styling.
struct SectionContainer<Content: View>: View {
    private let title: Text?
    private let spacing: CGFloat
    private let content: Content
    
    init(
        title: String? = nil,
        spacing: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        if let title {
            self.title = Text(title.localized)
        } else {
            self.title = nil
        }
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            if let title {
                HStack {
                    title
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
            }
            
            content
        }
        .sectionContainerStyle()
    }
}

// MARK: - Section Container Style

private struct SectionContainerStyle: ViewModifier {
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    func body(content: Content) -> some View {
        let cornerRadius = layoutMetrics.adaptive(28)
        
        return content
            .padding(layoutMetrics.adaptive(20))
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.thinMaterial)
                    .shadow(color: Color.black.opacity(0.08), radius: 14, y: 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.55),
                                        Color.white.opacity(0.12)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.8
                            )
                )
            )
    }
}

extension View {
    /// Applies the shared styling for section containers.
    func sectionContainerStyle() -> some View {
        modifier(SectionContainerStyle())
    }
}

