import SwiftUI

// MARK: - Main List Content
struct MainListContent: View {
    let onCategorySelected: (MainListModel.CategoryDestination) -> Void
    
    var body: some View {
        VStack {
            Spacer() // Push content to center
            
            VStack(spacing: MainScreenConstants.categorySpacing) {
                // Vertical list of all categories
                ListButtonContent(category: MainListModel.allCategories[0]) {
                    onCategorySelected(.startLearning)
                }
                
                ListButtonContent(category: MainListModel.allCategories[1]) {
                    onCategorySelected(.learnByTopics)
                }
                
                ListButtonContent(category: MainListModel.allCategories[2]) {
                    onCategorySelected(.favorites)
                }
                
                ListButtonContent(category: MainListModel.allCategories[3]) {
                    onCategorySelected(.takeTest)
                }
            }
            .padding(.horizontal, MainScreenConstants.categorySidePadding)
            
            Spacer() // Push content to center
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Main learning categories")
    }
}

// MARK: - Preview
#Preview {
    MainListContent { destination in
        print("Category selected: \(destination)")
    }
    .padding()
}
