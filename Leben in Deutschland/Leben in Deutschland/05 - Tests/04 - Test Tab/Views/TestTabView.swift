//
//  TestTabView.swift
//  Leben in Deutschland
//
//  Test tab view with Take a Test option display
//

import SwiftUI

struct TestTabView: View {
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var showDialog = false
    @State private var router = AppRouter()
    
    private var verticalSpacing: CGFloat { layoutMetrics.adaptive(28) }
    private var tabBarHeight: CGFloat { 49 }
    
    // Get the "Take a Test" option
    private var testOption: LearnOptionModel {
        LearnOptionModel(
            titleKey: "learn_option_test_title",
            descriptionKey: "learn_option_test_description",
            iconSystemName: "checkmark.seal",
            palette: LearnOptionPalette(
                gradientColors: [
                    Color("AppOrange"),
                    Color(red: 0.77, green: 0.21, blue: 0.12)
                ],
                accentColor: Color("AppOrange")
            )
        )
    }
    
    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            GeometryReader { geometry in
                VStack(spacing: verticalSpacing) {
                    LearnHeaderContent(showDialog: $showDialog)
                        .padding(.top, geometry.safeAreaInsets.top + layoutMetrics.adaptive(24))
                        .padding(.bottom, layoutMetrics.adaptive(20))
                    
                    VStack(spacing: layoutMetrics.adaptive(20)) {
                        // Title
                        Text(testOption.titleKey.localized)
                            .font(.system(.title, design: .rounded).weight(.bold))
                            .foregroundColor(testOption.palette.accentColor)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, layoutMetrics.adaptive(24))
                            .accessibilityAddTraits(.isHeader)
                        
                        // Moving icon
                        Button {
                            HapticManager.shared.lightImpact()
                            router.push(.testSimulation)
                        } label: {
                            TestOptionIconView(
                                option: testOption,
                                size: layoutMetrics.adaptive(68) * 1.5
                            )
                        }
                        .buttonStyle(.plain)
                        .frame(width: geometry.size.width, height: layoutMetrics.adaptive(240), alignment: .center)
                        
                        // Description card (explanation shield)
                        TestOptionDescriptionCardView(
                            option: testOption,
                            cornerRadius: layoutMetrics.adaptive(28),
                            horizontalInset: layoutMetrics.adaptive(20),
                            contentPadding: layoutMetrics.adaptive(22)
                        )
                    }
                    
                    Spacer()
                }
                .padding(.bottom, layoutMetrics.adaptive(32) + tabBarHeight + geometry.safeAreaInsets.bottom)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                .background(Color(.systemBackground))
            }
            .ignoresSafeArea(edges: .top)
            .navigationDestination(for: AppRouter.Destination.self) { destination in
                destinationView(for: destination)
            }
        }
        .toolbar(.visible, for: .tabBar)
        .environment(router)
        .onAppear {
            triggerDialog()
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: AppRouter.Destination) -> some View {
        switch destination {
        case .testSimulation:
            TestSessionView()
                .environmentObject(languageManager)
                .environmentObject(FavoritesManager.shared)
                .environmentObject(StateManager.shared)
        default:
            EmptyView()
        }
    }
    
    private func triggerDialog() {
        guard !showDialog else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                showDialog = true
            }
        }
    }
}

// MARK: - Test Option Icon View (Moving Icon)
private struct TestOptionIconView: View {
    let option: LearnOptionModel
    let size: CGFloat
    
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(option.palette.gradient)
                .opacity(0.35)
                .frame(width: size * 1.35, height: size * 1.35)
                .blur(radius: 24)
            
            Circle()
                .stroke(option.palette.accentColor.opacity(0.22), lineWidth: 2)
                .frame(width: size * 1.25, height: size * 1.25)
                .shadow(color: option.palette.accentColor.opacity(0.25), radius: 16, x: 0, y: 10)
            
            Image(systemName: option.iconSystemName)
                .font(.system(size: size, weight: .semibold))
                .symbolRenderingMode(.palette)
                .foregroundStyle(option.palette.accentColor)
                .accessibilityHidden(true)
                .scaleEffect(pulse ? 1.04 : 0.96)
                .animation(
                    .easeInOut(duration: 1.8)
                        .repeatForever(autoreverses: true),
                    value: pulse
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onAppear {
            pulse = true
        }
    }
}

// MARK: - Test Option Description Card (Explanation Shield)
private struct TestOptionDescriptionCardView: View {
    let option: LearnOptionModel
    let cornerRadius: CGFloat
    let horizontalInset: CGFloat
    let contentPadding: CGFloat
    
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    var body: some View {
        VStack(spacing: layoutMetrics.adaptive(12)) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.clear)
                .frame(height: contentPadding)
            
            VStack(alignment: .leading, spacing: layoutMetrics.adaptive(12)) {
                Text(option.descriptionKey.localized)
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .foregroundColor(option.palette.accentColor.opacity(0.95))
                    .lineSpacing(4)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityLabel(option.descriptionKey.localized)
            }
            .padding(contentPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        option.palette.gradient
                            .opacity(0.28)
                            .clipShape(
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(option.palette.accentColor.opacity(0.24), lineWidth: 1)
                    )
                    .shadow(color: option.palette.accentColor.opacity(0.14), radius: 20, x: 0, y: 14)
            )
        }
        .padding(.horizontal, horizontalInset)
    }
}

