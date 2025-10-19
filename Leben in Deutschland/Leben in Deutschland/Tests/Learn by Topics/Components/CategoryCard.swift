//
//  CategoryCard.swift
//  Leben in Deutschland
//
//  Reusable category card component
//

import SwiftUI

// MARK: - Category Card
struct CategoryCard: View {
    let category: CategoryModel
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            onTap()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Title
                Text(category.name)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Stats row
                HStack(spacing: 16) {
                    // Question count
                    HStack(spacing: 4) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Text("\(category.totalQuestions)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    // Subcategory count
                    HStack(spacing: 4) {
                        Image(systemName: "folder")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Text("\(category.subcategories.count)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Completion percentage
                    if category.completionPercentage > 0 {
                        Text("\(Int(category.completionPercentage * 100))%")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(Color("Fill"))
                    }
                }
                
                // Progress bar
                if category.completionPercentage > 0 {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 6)
                            
                            // Progress
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color("Fill"))
                                .frame(width: geometry.size.width * category.completionPercentage, height: 6)
                        }
                    }
                    .frame(height: 6)
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
        .accessibilityLabel("\(category.name), \(category.totalQuestions) questions")
        .accessibilityHint("Tap to view subcategories")
    }
}

// MARK: - Preview
#Preview {
    CategoryCard(
        category: CategoryModel(
            name: "Law and Constitution",
            subcategories: []
        ),
        onTap: {}
    )
    .padding()
}

