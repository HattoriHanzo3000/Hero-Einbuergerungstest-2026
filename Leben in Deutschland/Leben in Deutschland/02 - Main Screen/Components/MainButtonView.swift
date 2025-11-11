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
    
    private var iconColor: Color {
        switch category.destination {
        case .startLearning:
            return Color("AppGreenTerrace")
        case .learnByTopics:
            return Color("AppBlueLagoon")
        case .favorites:
            return Color("AppPink")
        case .takeTest:
            return Color("AppOrange")
        }
    }
    
    private var backgroundColor: Color {
        Color("MainButton")
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: MainScreenConstants.adaptiveValue(32))
            .fill(backgroundColor.opacity(0.75))
            .overlay(
                RoundedRectangle(cornerRadius: MainScreenConstants.adaptiveValue(28))
                    .fill(Color.white.opacity(0.28))
                    .padding(MainScreenConstants.adaptiveValue(16))
            .overlay(
                Image(systemName: category.icon)
                            .font(.system(.largeTitle, design: .rounded).weight(.semibold))
                            .foregroundColor(iconColor)
                    )
            )
            .frame(maxWidth: .infinity)
            .frame(height: MainScreenConstants.adaptiveValue(110))
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

