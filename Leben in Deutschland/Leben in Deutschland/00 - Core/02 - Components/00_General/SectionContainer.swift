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
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemGray6))
            .clipShape(
                RoundedRectangle(
                    cornerRadius: MainScreenConstants.adaptiveValue(28),
                    style: .continuous
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

