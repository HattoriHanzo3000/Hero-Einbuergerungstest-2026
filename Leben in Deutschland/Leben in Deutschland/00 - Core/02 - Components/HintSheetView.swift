//
//  HintSheetView.swift
//  Leben in Deutschland
//
//  Half sheet view to display hints for questions
//

import SwiftUI

struct HintSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutMetrics) private var layoutMetrics
    @Environment(\.colorScheme) private var colorScheme
    
    let hint: String
    var translatedHint: String? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: layoutMetrics.adaptive(20)) {
                    // Title section with liquid glass background
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: layoutMetrics.adaptive(24), weight: .semibold))
                            .foregroundColor(.white)
                            .accessibilityHidden(true)
                        
                        Text("hint_title".localized)
                            .font(.system(.title2, design: .rounded).weight(.bold).width(.condensed))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, layoutMetrics.adaptive(18))
                    .padding(.horizontal, layoutMetrics.adaptive(20))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(liquidGlassBackground)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: layoutMetrics.adaptive(24),
                            style: .continuous
                        )
                    )
                    .padding(.horizontal, layoutMetrics.adaptive(20))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("hint_title".localized)
                    
                    // Hint text
                    VStack(alignment: .leading, spacing: 0) {
                        Text(hint)
                            .font(.system(.body))
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityLabel(hint)
                        
                        // Translation of hint (when translation is active)
                        if let translatedHint = translatedHint, translatedHint != hint {
                            Text(translatedHint)
                                .font(.system(.footnote))
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, layoutMetrics.adaptive(24))
                    .padding(.bottom, layoutMetrics.adaptive(24))
                }
                .padding(.top, layoutMetrics.adaptive(24))
            }
            .scrollIndicators(.hidden)
            
            // Close button with liquid glass style
            Button(action: {
                HapticManager.shared.lightImpact()
                dismiss()
            }) {
                Text("close".localized.uppercased())
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, layoutMetrics.adaptive(18))
                    .background(
                        LinearGradient(
                            colors: [
                                Color("AppOrange").opacity(0.9),
                                Color("AppOrange").opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(layoutMetrics.adaptive(16))
                    .overlay(
                        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(16))
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.3),
                                        .white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.8
                            )
                    )
            }
            .accessibilityLabel("close".localized)
            .accessibilityHint("Closes the hint sheet")
            .accessibilityAddTraits(.isButton)
            .padding(.horizontal, layoutMetrics.adaptive(24))
            .padding(.top, layoutMetrics.adaptive(16))
            .padding(.bottom, layoutMetrics.adaptive(24))
            .background(Color(.systemBackground))
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground))
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private var liquidGlassBackground: some View {
        LiquidGlassBackground(gradient: .orange)
    }
}

// MARK: - Preview
#Preview {
    HintSheetView(hint: "This is a sample hint that helps you understand the question better. It provides additional context and guidance.")
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

