import SwiftUI

// MARK: - Main Screen Pro View
struct MainScreenProView: View {
    @State private var showDialog = false
    
    // Callbacks
    let onCategorySelected: (MainListModel.CategoryDestination) -> Void
    let onLanguageTapped: () -> Void
    let onDateTapped: () -> Void
    let onSettingsTapped: () -> Void
    let onPremiumTapped: () -> Void
    
    init(
        onCategorySelected: @escaping (MainListModel.CategoryDestination) -> Void = { _ in },
        onLanguageTapped: @escaping () -> Void = {},
        onDateTapped: @escaping () -> Void = {},
        onSettingsTapped: @escaping () -> Void = {},
        onPremiumTapped: @escaping () -> Void = {}
    ) {
        self.onCategorySelected = onCategorySelected
        self.onLanguageTapped = onLanguageTapped
        self.onDateTapped = onDateTapped
        self.onSettingsTapped = onSettingsTapped
        self.onPremiumTapped = onPremiumTapped
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.accentColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Mascot above central panel
                    MainMascotView(
                        messageKey: "welcome_message",
                        showDialog: $showDialog
                    )
                    .frame(height: 150)
                    .padding(.bottom, 20)
                    
                    // Central Liquid Glass Panel with 4 main buttons
                    CentralGlassPanel(
                        onCategorySelected: onCategorySelected
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                    
                    Spacer()
                    
                    // Bottom Liquid Glass Panel with utility buttons
                    BottomGlassPanel(
                        onLanguageTapped: onLanguageTapped,
                        onDateTapped: onDateTapped,
                        onSettingsTapped: onSettingsTapped,
                        onPremiumTapped: onPremiumTapped
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showDialog = true
            }
        }
    }
}

// MARK: - Central Glass Panel
struct CentralGlassPanel: View {
    let onCategorySelected: (MainListModel.CategoryDestination) -> Void
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        VStack(spacing: 16) {
            // 4 Main Category Buttons
            ForEach(MainListModel.allCategories) { category in
                GlassTextButton(
                    title: category.title.localized,
                    icon: category.icon,
                    action: {
                        HapticManager.shared.lightImpact()
                        onCategorySelected(category.destination)
                    }
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(.white.opacity(0.15), lineWidth: 0.5)
                }
        )
        .id(languageManager.currentAppLanguage)
    }
}

// MARK: - Bottom Glass Panel
struct BottomGlassPanel: View {
    let onLanguageTapped: () -> Void
    let onDateTapped: () -> Void
    let onSettingsTapped: () -> Void
    let onPremiumTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Language button
            GlassIconButton(
                icon: "globe",
                action: onLanguageTapped
            )
            
            // Date picker button
            GlassIconButton(
                icon: "calendar",
                action: onDateTapped
            )
            
            // Premium button
            GlassIconButton(
                icon: "crown.fill",
                action: onPremiumTapped
            )
            
            // Settings button
            GlassIconButton(
                icon: "gearshape.fill",
                action: onSettingsTapped
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(.white.opacity(0.15), lineWidth: 0.5)
                }
        )
    }
}

// MARK: - Glass Text Button
struct GlassTextButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Glass Icon Button
struct GlassIconButton: View {
    let icon: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.lightImpact()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Preview
#Preview {
    MainScreenProView()
        .environmentObject(LanguageManager())
}

