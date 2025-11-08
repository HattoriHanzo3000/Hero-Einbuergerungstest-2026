import SwiftUI

// MARK: - Main List Content
struct MainListContent: View {
    let onCategorySelected: (MainListModel.CategoryDestination) -> Void
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        VStack {
            Spacer() // Push content to center
            
            VStack(spacing: MainScreenConstants.categorySpacing) {
                // Vertical list of all categories
                
                // Start Learning - Regular button (will be NavigationLink later)
                MainButton(category: MainListModel.allCategories[0]) {
                    onCategorySelected(.startLearning)
                }
                
                // Learn by Topics - Router navigation
                MainButton(category: MainListModel.allCategories[1]) {
                    router.push(.categories)
                }
                
                // Favorites - Regular button (will be NavigationLink later)
                MainButton(category: MainListModel.allCategories[2]) {
                    onCategorySelected(.favorites)
                }
                
                // Take Test - Regular button (will be NavigationLink later)
                MainButton(category: MainListModel.allCategories[3]) {
                    onCategorySelected(.takeTest)
                }
            }
            .padding(.horizontal, MainScreenConstants.categorySidePadding)
            .id(languageManager.currentAppLanguage)
            
            Spacer() // Push content to center
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Main learning categories")
    }
}

// MARK: - Main Button (with action)
private struct MainButton: View {
    let category: MainListModel
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            action()
        }) {
            MainButtonView(category: category)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}


// MARK: - Preview
#Preview {
    @Previewable @State var router = AppRouter()
    
    NavigationStack(path: $router.navigationPath) {
        MainListContent { destination in
            print("Category selected: \(destination)")
        }
        .environmentObject(LanguageManager())
        .environment(router)
        .padding()
    }
}
