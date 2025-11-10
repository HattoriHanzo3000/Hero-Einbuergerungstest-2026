import SwiftUI

// MARK: - Main List Content
struct MainListContent: View {
    let fillHeight: Bool
    let onCategorySelected: (MainListModel.CategoryDestination) -> Void
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(AppRouter.self) private var router
    
    init(
        fillHeight: Bool = false,
        onCategorySelected: @escaping (MainListModel.CategoryDestination) -> Void
    ) {
        self.fillHeight = fillHeight
        self.onCategorySelected = onCategorySelected
    }
    
    private var stackSpacing: CGFloat {
        MainScreenConstants.adaptiveValue(16)
    }
    
    var body: some View {
        VStack {
            Spacer(minLength: MainScreenConstants.adaptiveValue(8))
            
            VStack(spacing: stackSpacing) {
                ForEach(MainListModel.allCategories) { category in
                    MainButton(category: category) {
                        switch category.destination {
                        case .startLearning:
                    onCategorySelected(.startLearning)
                        case .learnByTopics:
                    router.push(.categories)
                        case .favorites:
                            onCategorySelected(.favorites)
                        case .takeTest:
                            onCategorySelected(.takeTest)
                }
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityAddTraits(.isButton)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, MainScreenConstants.adaptiveValue(24))
            .padding(.horizontal, MainScreenConstants.adaptiveValue(20))
            .background(
                RoundedRectangle(cornerRadius: MainScreenConstants.adaptiveValue(32))
                    .fill(Color("MainButton").opacity(0.65))
            )
            .padding(.horizontal, MainScreenConstants.adaptiveValue(12))
            .frame(minHeight: fillHeight ? MainScreenConstants.getScreenHeight() * 0.5 : nil, alignment: .top)
            .id(languageManager.currentAppLanguage)
            
            Spacer(minLength: MainScreenConstants.adaptiveValue(8))
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
    @State private var pulsateScale: CGFloat = 0.95
    
    var body: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            action()
        }) {
            MainButtonView(category: category)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : pulsateScale)
        .animation(.easeInOut(duration: 0.12), value: isPressed)
        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: pulsateScale)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .accessibilityLabel(category.accessibilityLabel.localized)
        .accessibilityHint(category.accessibilityHint.localized)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                pulsateScale = 1.07
            }
        }
        .onDisappear {
            pulsateScale = 0.95
        }
    }
}


// MARK: - Preview
#Preview {
    @Previewable @State var router = AppRouter()
    
    NavigationStack(path: $router.navigationPath) {
        MainListContent(fillHeight: false) { destination in
            print("Category selected: \(destination)")
        }
        .environmentObject(LanguageManager())
        .environment(router)
        .padding()
    }
}
