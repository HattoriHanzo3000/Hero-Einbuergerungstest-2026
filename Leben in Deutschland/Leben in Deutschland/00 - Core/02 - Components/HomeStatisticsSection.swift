import SwiftUI

// MARK: - Home Statistics Section
/// Displays the learner's readiness using the B2 Beruf–style multi-ring chart and gradient stat cards.
struct HomeStatisticsSection: View {
    let statistics: HomeStatisticsModel
    @Environment(\.layoutMetrics) private var layoutMetrics
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var showExplanationSheet = false

    private var statisticsContent: some View {
        VStack(spacing: layoutMetrics.adaptive(20)) {
            HomeRingChartView(
                progress: (familiar: statistics.familiar, reinforced: statistics.reinforced, mastered: statistics.mastered, expert: statistics.expert, total: statistics.totalQuestions),
                readinessPercentage: statistics.readinessPercentage
            )
            .frame(maxWidth: .infinity)
            .frame(height: layoutMetrics.adaptive(320))

            HomeStatisticsGridView(statistics: statistics)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var titleRow: some View {
        HStack {
            Text("home_statistics_title".localized)
                .font(.system(.title3, weight: .light).width(.compressed))
                .foregroundColor(.primary)
            Spacer()
            Button {
                showExplanationSheet = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(.title3))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("progress_readiness_info_accessibility_label".localized)
            .accessibilityHint("progress_readiness_info_accessibility_hint".localized)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: layoutMetrics.adaptive(18)) {
            titleRow
            statisticsContent
        }
        .sheet(isPresented: $showExplanationSheet) {
            LearnModeDisclaimerSheet(
                titleKey: "home_statistics_title",
                messageKey: "progress_readiness_explanation",
                messageFormatted: String(format: "progress_readiness_explanation_full".localized, statistics.totalQuestions, "home_learn_spaced_repetition".localized, "learn_option_test_title".localized),
                accentColor: Color.accentColor,
                doNotShowAgain: .constant(false),
                showDoNotShowAgain: false,
                onDismiss: { showExplanationSheet = false }
            )
            .environmentObject(languageManager)
            .environment(\.layoutMetrics, layoutMetrics)
        }
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Ring Chart View (B2-style multi-ring)
private struct HomeRingChartView: View {
    let progress: (familiar: Int, reinforced: Int, mastered: Int, expert: Int, total: Int)
    let readinessPercentage: Int

    @State private var isPulsing = false
    @Environment(\.layoutMetrics) private var layoutMetrics
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var ringThickness: CGFloat { layoutMetrics.adaptive(70) }
    private var baseRadius: CGFloat { layoutMetrics.adaptive(130) }
    private var chartSize: CGFloat { baseRadius * 2 }

    private var rings: [(value: Double, color: Color, maxValue: Int)] {
        let total = Double(max(progress.total, 1))
        let backgroundRingColor = Color(.systemGray4)
        let backgroundRing = (1.0, backgroundRingColor, 0)
        let dataRings = [
            (Double(progress.expert) / total, Color("AppGreen"), progress.expert),
            (Double(progress.mastered) / total, Color("AppBlue"), progress.mastered),
            (Double(progress.reinforced) / total, Color("AppOrange"), progress.reinforced),
            (Double(progress.familiar) / total, Color("AppPink"), progress.familiar)
        ]
        let sortedDataRings = dataRings.sorted { $0.2 > $1.2 }
        return [backgroundRing] + sortedDataRings
    }

    var body: some View {
        ZStack {
            ForEach(Array(rings.enumerated()), id: \.offset) { index, ring in
                HomeRingView(
                    progress: ring.value,
                    color: ring.color,
                    ringIndex: index,
                    totalRings: rings.count,
                    ringThickness: ringThickness,
                    baseRadius: baseRadius
                )
            }

            Text("\(readinessPercentage)%")
                .font(.system(.title2, design: .default).weight(.bold).width(.expanded))
                .foregroundColor(.primary)
                .frame(width: chartSize, height: chartSize)
                .contentShape(Rectangle())
                .scaleEffect(isPulsing ? 1.1 : 1.0)
                .onAppear {
                    guard !reduceMotion else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                            isPulsing = true
                        }
                    }
                }
                .onDisappear { isPulsing = false }
        }
        .frame(width: chartSize, height: chartSize)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("home_statistics_accessibility_label".localized)
        .accessibilityValue(String(format: "home_statistics_accessibility_value".localized, readinessPercentage))
    }
}

// MARK: - Single Ring View
private struct HomeRingView: View {
    let progress: Double
    let color: Color
    let ringIndex: Int
    let totalRings: Int
    let ringThickness: CGFloat
    let baseRadius: CGFloat

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.clear, lineWidth: ringThickness)
                .frame(width: baseRadius * 2, height: baseRadius * 2)

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(color, style: StrokeStyle(lineWidth: ringThickness, lineCap: .round))
                .frame(width: baseRadius * 2, height: baseRadius * 2)
                .rotationEffect(.degrees(-90))
        }
        .onAppear {
            if ringIndex == 0 {
                animatedProgress = progress
            } else {
                animatedProgress = 0
                withAnimation(.easeOut(duration: 1.0).delay(Double(ringIndex - 1) * 0.15)) {
                    animatedProgress = progress
                }
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Statistics Grid View (B2-style 2x2 gradient cards)
private struct HomeStatisticsGridView: View {
    let statistics: HomeStatisticsModel
    @Environment(\.layoutMetrics) private var layoutMetrics

    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: layoutMetrics.adaptive(12)),
            GridItem(.flexible(), spacing: layoutMetrics.adaptive(12))
        ]
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: layoutMetrics.adaptive(12)) {
            HomeStatisticsGridCard(
                titleKey: "statistics_familiar_title",
                count: statistics.familiar,
                descriptionKey: "statistics_familiar_description",
                gradient: LinearGradient(
                    colors: [
                        Color("AppPink"),
                        Color("AppPink").opacity(0.9),
                        Color("AppPink").opacity(0.75)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                layoutMetrics: layoutMetrics
            )
            HomeStatisticsGridCard(
                titleKey: "statistics_reinforced_title",
                count: statistics.reinforced,
                descriptionKey: "statistics_reinforced_description",
                gradient: LinearGradient(
                    colors: [
                        Color("AppOrange"),
                        Color("AppOrange").opacity(0.9),
                        Color("AppOrange").opacity(0.75)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                layoutMetrics: layoutMetrics
            )
            HomeStatisticsGridCard(
                titleKey: "statistics_mastered_title",
                count: statistics.mastered,
                descriptionKey: "statistics_mastered_description",
                gradient: LinearGradient(
                    colors: [
                        Color("AppBlue"),
                        Color("AppBlue").opacity(0.9),
                        Color("AppBlue").opacity(0.75)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                layoutMetrics: layoutMetrics
            )
            HomeStatisticsGridCard(
                titleKey: "statistics_expert_title",
                count: statistics.expert,
                descriptionKey: "statistics_expert_description",
                gradient: LinearGradient(
                    colors: [
                        Color("AppGreen"),
                        Color("AppGreen").opacity(0.9),
                        Color("AppGreen").opacity(0.75)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                layoutMetrics: layoutMetrics
            )
        }
    }
}

// MARK: - Statistics Grid Card (B2-style gradient card, flips to show description; flips back after 10 s)
private struct HomeStatisticsGridCard: View {
    let titleKey: String
    let count: Int
    let descriptionKey: String
    let gradient: LinearGradient
    let layoutMetrics: LayoutMetrics

    @State private var isFlipped = false
    @State private var flipBackTask: Task<Void, Never>?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let flipBackDelay: TimeInterval = 10

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: layoutMetrics.adaptive(16), style: .continuous)
            .fill(gradient)
            .overlay(
                RoundedRectangle(cornerRadius: layoutMetrics.adaptive(16), style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.2), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
    }

    var body: some View {
        ZStack {
            frontFace
                .opacity(isFlipped ? 0 : 1)
            backFace
                .rotation3DEffect(reduceMotion ? .degrees(0) : .degrees(180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)
        }
        .rotation3DEffect(reduceMotion ? .degrees(0) : .degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .frame(minHeight: layoutMetrics.adaptive(100))
        .contentShape(Rectangle())
        .onTapGesture {
            HapticManager.shared.lightImpact()
            flipCard()
        }
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("\(titleKey.localized) – \(count)")
        .accessibilityValue(descriptionKey.localized)
        .accessibilityHint("statistics_card_flip_hint".localized)
    }

    private func flipCard() {
        flipBackTask?.cancel()
        withAnimation(reduceMotion ? .easeInOut(duration: 0.25) : .spring(response: 0.4, dampingFraction: 0.75)) {
            isFlipped.toggle()
        }
        if isFlipped {
            flipBackTask = Task {
                try? await Task.sleep(nanoseconds: UInt64(flipBackDelay * 1_000_000_000))
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    withAnimation(reduceMotion ? .easeInOut(duration: 0.25) : .spring(response: 0.4, dampingFraction: 0.75)) {
                        isFlipped = false
                    }
                }
            }
        }
    }

    /// Front: row 1 = count, row 2 = level title (Familiar, Reinforced, Mastered, Expert).
    private var frontFace: some View {
        VStack(alignment: .leading, spacing: layoutMetrics.adaptive(8)) {
            Text("\(count)")
                .font(.system(.title3, design: .default).weight(.regular).width(.expanded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(titleKey.localized)
                .font(.system(.subheadline, design: .default).weight(.medium).width(.condensed))
                .foregroundColor(.white.opacity(0.95))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(layoutMetrics.adaptive(16))
        .frame(maxWidth: .infinity, minHeight: layoutMetrics.adaptive(100), alignment: .leading)
        .background(cardBackground)
    }

    private var backFace: some View {
        VStack(alignment: .leading, spacing: layoutMetrics.adaptive(8)) {
            Text(descriptionKey.localized)
                .font(.system(.footnote, design: .default).weight(.medium).width(.condensed))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(layoutMetrics.adaptive(16))
        .frame(maxWidth: .infinity, minHeight: layoutMetrics.adaptive(100), alignment: .leading)
        .background(cardBackground)
    }
}

// MARK: - Preview
#Preview {
    HomeStatisticsSection(
        statistics: HomeStatisticsModel(
            readinessPercentage: 72,
            familiar: 86,
            reinforced: 54,
            mastered: 158,
            expert: 12,
            totalQuestions: LayoutMetrics.totalFederalQuestions
        )
    )
    .environmentObject(LanguageManager())
    .padding()
    .background(Color(.systemBackground))
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
