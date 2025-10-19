import SwiftUI

// MARK: - List Button Content
struct ListButtonContent: View {
    let category: MainListModel
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            action()
        }) {
            HStack(alignment: .center, spacing: 16) {
                // Square icon container
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("MainButton"))
                        .frame(width: MainScreenConstants.categoryIconSize, height: MainScreenConstants.categoryIconSize)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("MainButtonText"))
                }
                
                // Rectangle text container
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
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
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .accessibilityLabel(category.accessibilityLabel)
        .accessibilityHint(category.accessibilityHint)
        .accessibilityAddTraits(.isButton)
    }
}


// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        ListButtonContent(category: MainListModel.allCategories[0]) {
            print("Start Learning tapped")
        }
        
        ListButtonContent(category: MainListModel.allCategories[1]) {
            print("Learn by Topics tapped")
        }
    }
    .padding()
}
