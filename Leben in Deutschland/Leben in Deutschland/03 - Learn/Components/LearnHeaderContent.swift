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
    
    private var topPadding: CGFloat { MainScreenConstants.adaptiveValue(56) }
    private var bottomPadding: CGFloat { MainScreenConstants.adaptiveValue(18) }
    private var horizontalPadding: CGFloat { MainScreenConstants.adaptiveValue(24) }
    private var interItemSpacing: CGFloat { MainScreenConstants.adaptiveValue(12) }
    
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
            skyGradientBackground
                .ignoresSafeArea(edges: .top)
        }
        .shadow(color: Color.black.opacity(0.08), radius: 12, y: 10)
        .accessibilityAddTraits(.isHeader)
    }
}

private extension LearnHeaderContent {
    var skyGradientBackground: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color("AppBlueLagoon").opacity(0.45),
                            Color("AppBlueLagoon").opacity(0.18),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var showDialog = true
    
    LearnHeaderContent(showDialog: $showDialog)
        .environmentObject(LanguageManager())
}

