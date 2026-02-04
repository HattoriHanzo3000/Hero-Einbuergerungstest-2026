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
                            .font(.system(.title2, design: .rounded).weight(.bold))
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
                    Text(hint)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, layoutMetrics.adaptive(24))
                        .padding(.bottom, layoutMetrics.adaptive(24))
                        .accessibilityLabel(hint)
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
    
    // MARK: - Liquid Glass Background
    private var liquidGlassBackground: some View {
        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(24), style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color("AppOrange").opacity(0.9),
                        Color("AppOrange").opacity(0.65),
                        Color("AppOrange").opacity(0.45)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.20),
                        Color.white.opacity(0.05),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(24), style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.45),
                                Color.white.opacity(0.12)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.8
                    )
            )
    }
}

// MARK: - Preview
#Preview {
    HintSheetView(hint: "This is a sample hint that helps you understand the question better. It provides additional context and guidance.")
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

