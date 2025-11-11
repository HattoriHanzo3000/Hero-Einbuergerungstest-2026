//
//  LearnView.swift
//  Leben in Deutschland
//
//  Launchpad for the Learn experience with a bold editorial header and curated pathways.
//

import SwiftUI

// MARK: - Learn View
struct LearnView: View {
    @StateObject private var optionsViewModel = LearnOptionsViewModel()
    @State private var showDialog = false
    
    private var horizontalSafeInset: CGFloat { MainScreenConstants.adaptiveValue(24) }
    private var verticalSpacing: CGFloat { MainScreenConstants.adaptiveValue(28) }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: verticalSpacing) {
                LearnHeaderContent(showDialog: $showDialog)
                    .padding(.top, geometry.safeAreaInsets.top + MainScreenConstants.adaptiveValue(24))
                    .padding(.bottom, MainScreenConstants.adaptiveValue(20))
                
                VStack(spacing: verticalSpacing) {
                    LearnOptionsCarouselView(
                        options: optionsViewModel.options,
                        onSelect: handleSelection,
                        containerWidth: geometry.size.width,
                        horizontalSafeInset: 0
                    )
                    
                    Spacer()
                }
            }
            .padding(.bottom, MainScreenConstants.adaptiveValue(32))
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
            .background(Color(.systemBackground))
        }
        .ignoresSafeArea(edges: .top)
        .onAppear(perform: triggerDialog)
    }
}

// MARK: - Private Methods
private extension LearnView {
    func handleSelection(_ option: LearnOptionModel) {
        optionsViewModel.select(option)
    }
    
    func triggerDialog() {
        guard !showDialog else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                showDialog = true
            }
        }
    }
}

// MARK: - Preview
#Preview("Learn View – Hero Header") {
    LearnView()
        .environmentObject(LanguageManager())
}


