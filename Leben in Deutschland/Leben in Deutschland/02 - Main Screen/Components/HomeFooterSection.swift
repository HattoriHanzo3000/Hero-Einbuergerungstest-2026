import SwiftUI

/// Footer accent section extending the hero warmth with an upward orange gradient.
struct HomeFooterSection: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    private var cornerRadius: CGFloat { layoutMetrics.adaptive(32) }
    private var height: CGFloat { layoutMetrics.adaptive(180) }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(gradient)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderGradient, lineWidth: 1)
            )
            .frame(height: height)
            .shadow(color: Color("AppOrange").opacity(0.18), radius: 18, y: 12)
            .accessibilityHidden(true)
    }
}

private extension HomeFooterSection {
    var gradient: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppOrange").opacity(0.92),
                Color("AppOrange").opacity(0.58),
                Color("AppOrange").opacity(0.18),
                Color.clear
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }
    
    var borderGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.35),
                Color.white.opacity(0.05)
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }
}

#Preview {
    HomeFooterSection()
        .padding(24)
        .background(Color(.systemBackground))
}

