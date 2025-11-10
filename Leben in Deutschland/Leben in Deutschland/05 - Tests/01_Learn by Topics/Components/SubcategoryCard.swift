//
//  SubcategoryCard.swift
//  Leben in Deutschland
//
//  Reusable subcategory card component
//

import SwiftUI

// MARK: - Subcategory Card
struct SubcategoryCard: View {
    let subcategory: SubcategoryModel
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            onTap()
        }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    Text(subcategory.name)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    // Question count
                    HStack(spacing: 4) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        if subcategory.answeredCount > 0 {
                            Text("\(subcategory.answeredCount)/\(subcategory.questionCount)")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        } else {
                            Text("\(subcategory.questionCount)")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Completion indicator
                if subcategory.completionPercentage > 0 {
                    VStack(spacing: 4) {
                        Text("\(Int(subcategory.completionPercentage * 100))%")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(Color("Fill"))
                        
                        // Circular progress
                        ZStack {
                            Circle()
                                .stroke(Color(.systemGray5), lineWidth: 3)
                                .frame(width: 32, height: 32)
                            
                            Circle()
                                .trim(from: 0, to: subcategory.completionPercentage)
                                .stroke(Color("Fill"), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .frame(width: 32, height: 32)
                                .rotationEffect(.degrees(-90))
                        }
                    }
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.08), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibilityLabel("\(subcategory.name), \(subcategory.questionCount) questions")
        .accessibilityHint("Tap to start quiz")
    }
}

// MARK: - Preview
#Preview {
    SubcategoryCard(
        subcategory: SubcategoryModel(
            name: "Basic Law",
            categoryName: "Law and Constitution",
            questions: []
        ),
        onTap: {}
    )
    .padding()
}

