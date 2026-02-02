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
            // Handle bar
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(.systemGray6).opacity(0.5))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: layoutMetrics.adaptive(20)) {
                    // Title section with liquid glass background
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: layoutMetrics.adaptive(24), weight: .semibold))
                            .foregroundColor(Color(.systemGray6))
                        
                        Text("hint_title".localized)
                            .font(.system(.title2, design: .rounded).weight(.bold))
                            .foregroundColor(Color(.systemGray6))
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
                    
                    // Hint text
                    Text(hint)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                        .padding(.horizontal, layoutMetrics.adaptive(24))
                        .padding(.bottom, layoutMetrics.adaptive(24))
                }
            }
            
            // Close button with liquid glass style
            Button(action: {
                HapticManager.shared.lightImpact()
                dismiss()
            }) {
                Text("close".localized)
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: layoutMetrics.adaptive(50))
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
            .padding(.horizontal, layoutMetrics.adaptive(24))
            .padding(.bottom, layoutMetrics.adaptive(24))
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: layoutMetrics.adaptive(24), style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 20, y: -5)
        )
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
                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(28), style: .continuous)
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

