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
        HStack(alignment: .center, spacing: 16) {
            // Square icon container
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color("MainButton"))
                    .frame(width: MainScreenConstants.categoryIconSize, height: MainScreenConstants.categoryIconSize)
                
                Image(systemName: category.icon)
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("MainButtonText"))
            }
            
            // Rectangle text container
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color("MainButton"))
                    .frame(height: MainScreenConstants.categoryIconSize)
                
                Text(category.title.localized)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundColor(Color("MainButtonText"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: MainScreenConstants.categoryButtonHeight)
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

