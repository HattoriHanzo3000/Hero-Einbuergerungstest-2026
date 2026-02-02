//
//  LearnHeaderContent.swift
//  Leben in Deutschland
//
//  Heroic header for the Learn hub, mirroring the main screen styling while focusing on upcoming content.
//

import SwiftUI

// MARK: - Learn Header Content
struct LearnHeaderContent: View {
    @Binding var showDialog: Bool
    
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    private var topPadding: CGFloat { layoutMetrics.adaptive(56) }
    private var bottomPadding: CGFloat { layoutMetrics.adaptive(18) }
    private var horizontalPadding: CGFloat { layoutMetrics.adaptive(24) }
    private var interItemSpacing: CGFloat { layoutMetrics.adaptive(12) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: interItemSpacing) {
            MainMascotView(
                messageKey: "learn_header_dialog_message",
                showDialog: $showDialog,
                autoPlayInterval: 45
            )
        }
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
        .padding(.horizontal, horizontalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            HeroHeaderBackground()
                .ignoresSafeArea(edges: .top)
        }
        .shadow(color: Color.black.opacity(0.08), radius: 12, y: 10)
        .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var showDialog = true
    
    LearnHeaderContent(showDialog: $showDialog)
        .environmentObject(LanguageManager())
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

