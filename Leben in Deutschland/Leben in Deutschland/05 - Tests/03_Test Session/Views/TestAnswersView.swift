//
//  TestAnswersView.swift
//  Leben in Deutschland
//
//  View for reviewing all test answers with correct/incorrect highlights
//

import SwiftUI

struct TestAnswersView: View {
    @ObservedObject var viewModel: TestSessionViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager
    @EnvironmentObject private var favoritesManager: FavoritesManager
    
    @State private var currentQuestionIndex: Int = 0
    @State private var lastHorizontalScrollHapticTs: Double = 0.0
    @State private var showTranslation: Bool = false
    @State private var translatedQuestion: QuestionModel?
    @State private var showingFeedbackReport = false
    
    private let contentService = ContentService.shared
    
    private struct ZoomedAsset: Identifiable {
        let id = UUID()
        let name: String
    }
    @State private var zoomedAsset: ZoomedAsset?
    
    private var currentQuestion: TestQuestion? {
        guard currentQuestionIndex < viewModel.questions.count else { return nil }
        return viewModel.questions[currentQuestionIndex]
    }
    
    var body: some View {
        GeometryReader { bodyGeometry in
            let screenHeight = bodyGeometry.size.height
            
            VStack(spacing: 0) {
                headerView(screenHeight: screenHeight)
                answersContent
                navigationBar
            }
            .background(Color(.systemBackground))
        }
        .fontDesign(.rounded)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .hidesTabBar()
        .sheet(isPresented: $showingFeedbackReport) {
            if let q = currentQuestion {
                FeedbackReportView(
                    questionId: q.originalId,
                    questionText: q.text,
                    category: q.category
                )
                .environmentObject(languageManager)
            }
        }
    }
    
    // MARK: - Header
    private func headerView(screenHeight: CGFloat) -> some View {
        let titleHeight = screenHeight * 0.06
        let actionHeight = screenHeight * 0.08
        
        return VStack(spacing: 0) {
            // Title block
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let sidePadding = screenWidth * 0.05
                
                ZStack {
                    HStack {
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            dismiss()
                        }) {
                            Image(systemName: "chevron.down")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGray6))
                        }
                        .padding(.leading, sidePadding)
                        Spacer()
                    }
                    
                    Text("your_answers".localized)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color(.systemGray6))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: titleHeight)
            
            // Action block
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let sidePadding = screenWidth * 0.05
                
                ZStack {
                    HStack(spacing: 4) {
                        if let q = currentQuestion {
                            HStack(spacing: 8) {
                                Text("\("question_label".localized) \(q.originalId)")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(.systemGray6))
                                
                                Button(action: {
                                    HapticManager.shared.lightImpact()
                                    showingFeedbackReport = true
                                }) {
                                    Image(systemName: "flag.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Color.accentColor)
                                }
                            }
                            .padding(.leading, sidePadding)
                            .frame(maxHeight: .infinity, alignment: .center)
                            .offset(y: 1)
                        }
                        Spacer()
                        
                        // Globe icon (toggle translation)
                        Button(action: {
                            HapticManager.shared.lightImpact()
                            showTranslation.toggle()
                        }) {
                            Image(systemName: "globe")
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                                .foregroundColor(showTranslation ? Color.blue.opacity(0.9) : Color(.systemGray6))
                        }
                        .padding(.trailing, 12)
                        
                        // Favorite icon
                        if let q = currentQuestion {
                            Button(action: {
                                HapticManager.shared.lightImpact()
                                favoritesManager.toggleFavorite(for: q.originalId)
                            }) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                                    .foregroundColor(favoritesManager.isFavorite(q.originalId) ? Color("AppPink") : Color(.systemGray6))
                            }
                            .padding(.trailing, sidePadding)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: actionHeight)
        }
        .frame(height: titleHeight + actionHeight)
        .background(
            RoundedRectangle(cornerRadius: 0, style: .continuous)
                .fill(Color("ProgressOrange"))
                .clipShape(
                    RoundedCorner(radius: 35, corners: [.bottomLeft, .bottomRight])
                )
                .ignoresSafeArea(.all, edges: .top)
        )
    }
    
    // MARK: - Content
    private var answersContent: some View {
        ScrollView {
            VStack(spacing: layoutMetrics.adaptive(20)) {
                if let q = currentQuestion {
                    answerContent(for: q)
                }
            }
        }
        .task(id: "\(currentQuestion?.originalId ?? "")-\(showTranslation)") {
            if showTranslation, let questionId = currentQuestion?.originalId {
                translatedQuestion = await contentService.getQuestion(id: questionId, in: languageManager.currentTranslationLanguage)
            } else {
                translatedQuestion = nil
            }
        }
    }
    
    @ViewBuilder
    private func answerContent(for q: TestQuestion) -> some View {
        let userAnswer = viewModel.answers.first(where: { $0.questionId == q.id })
        let assetName = contentService.getIllustrationAsset(for: q.originalId)
        
        // Question illustration
        if let assetName = assetName {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 280)
                .padding(.horizontal, layoutMetrics.adaptive(22))
                .padding(.top, layoutMetrics.adaptive(8))
                .onTapGesture {
                    HapticManager.shared.lightImpact()
                    zoomedAsset = ZoomedAsset(name: assetName)
                }
        }
        
        // Convert TestQuestion to QuestionModel for QuestionCard
        let questionModel = QuestionModel(
            id: q.originalId,
            text: q.text,
            options: q.options,
            category: q.category,
            subcategory: nil
        )
        
        QuestionCard(
            question: questionModel,
            selectedAnswer: userAnswer?.selectedIndex,
            showCorrectAnswer: true, // Show correct/incorrect answers in review
            showTranslation: showTranslation,
            onAnswerSelected: { _ in } // Answers are read-only in review
        )
        .padding(.bottom, layoutMetrics.adaptive(80))
    }
    
    // MARK: - Navigation
    private var navigationBar: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Button(action: {
                    HapticManager.shared.lightImpact()
                    if currentQuestionIndex > 0 { currentQuestionIndex -= 1 }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(currentQuestionIndex > 0 ? Color("ProgressOrange") : Color.gray)
                        Text("back".localized)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(currentQuestionIndex > 0 ? Color("ProgressOrange") : Color.gray)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                }
                .disabled(currentQuestionIndex == 0)
                
                Spacer()
                
                Button(action: {
                    HapticManager.shared.lightImpact()
                    if currentQuestionIndex < viewModel.questions.count - 1 {
                        currentQuestionIndex += 1
                    }
                }) {
                    HStack(spacing: 4) {
                        Text("next".localized)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(currentQuestionIndex < viewModel.questions.count - 1 ? Color("ProgressOrange") : Color.gray)
                    }
                    .foregroundColor(currentQuestionIndex < viewModel.questions.count - 1 ? Color("ProgressOrange") : Color.gray)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                }
                .disabled(currentQuestionIndex == viewModel.questions.count - 1)
            }
            .padding(.horizontal)
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<viewModel.questions.count, id: \.self) { index in
                            Button(action: {
                                HapticManager.shared.lightImpact()
                                currentQuestionIndex = index
                            }) {
                                Text("\(index + 1)")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(circleTextColor(for: index))
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(circleBackgroundColor(for: index))
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .id(index)
                        }
                    }
                    .padding(.horizontal, 20)
                    .simultaneousGesture(DragGesture().onChanged { _ in
                        let now = Date().timeIntervalSince1970
                        if now - lastHorizontalScrollHapticTs > 0.2 {
                            lastHorizontalScrollHapticTs = now
                            HapticManager.shared.lightImpact()
                        }
                    })
                }
                .onChange(of: currentQuestionIndex) { _, newIndex in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                    HapticManager.shared.lightImpact()
                }
            }
            .padding(.bottom, 32)
        }
        .fullScreenCover(item: $zoomedAsset) { item in
            ZStack {
                Color.black.opacity(0.8).ignoresSafeArea()
                    .onTapGesture { zoomedAsset = nil }
                ZoomableImage(imageName: item.name)
                    .padding(24)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Helpers
    private func circleTextColor(for index: Int) -> Color {
        return index == currentQuestionIndex ? .white : .primary.opacity(0.6)
    }
    
    private func circleBackgroundColor(for index: Int) -> Color {
        return index == currentQuestionIndex ? Color("ProgressOrange") : Color(.systemGray5)
    }
    
}

