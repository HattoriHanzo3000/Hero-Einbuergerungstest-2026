//
//  MainButtonView.swift
//  Leben in Deutschland
//
//  Reusable main button appearance (visual only, no action)
//

import SwiftUI

// MARK: - Main Button View (Visual Only)
struct MainButtonView: View {
    let category: MainListModel
    
    var body: some View {
        HStack(alignment: .center, spacing: MainScreenConstants.adaptiveValue(10)) {
            iconContainer
            textContainer
        }
        .padding(.vertical, MainScreenConstants.adaptiveValue(12))
        .padding(.horizontal, MainScreenConstants.adaptiveValue(12))
        .background(
            RoundedRectangle(cornerRadius: MainScreenConstants.adaptiveValue(26))
                .fill(backgroundColor)
        )
    }
    
    private var contentColor: Color {
        Color("MainButtonText")
    }
    
    private var backgroundColor: Color {
        Color("MainButton")
    }
    
    private var iconContainer: some View {
        RoundedRectangle(cornerRadius: MainScreenConstants.adaptiveValue(24))
            .fill(Color("MainButton").opacity(0.22))
            .overlay(
                Image(systemName: category.icon)
                    .font(.system(.title3, design: .rounded).weight(.semibold))
                    .foregroundColor(contentColor)
            )
            .frame(
                width: MainScreenConstants.adaptiveValue(48),
                height: MainScreenConstants.adaptiveValue(48)
            )
    }
    
    private var textContainer: some View {
        Text(category.title.localized)
            .font(.system(.title2, design: .rounded).weight(.semibold))
            .foregroundColor(contentColor)
            .multilineTextAlignment(.leading)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        MainButtonView(category: MainListModel.allCategories[0])
        MainButtonView(category: MainListModel.allCategories[1])
    }
    .padding()
}

