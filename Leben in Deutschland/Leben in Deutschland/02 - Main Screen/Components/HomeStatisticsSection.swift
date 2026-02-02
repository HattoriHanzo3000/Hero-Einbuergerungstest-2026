import SwiftUI

// MARK: - Home Statistics Section
/// Displays the learner's readiness as a radial progress indicator with contextual messaging.
struct HomeStatisticsSection: View {
    let statistics: HomeStatisticsModel
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    private var normalizedProgress: Double {
        let clamped = min(max(statistics.readinessPercentage, 0), 100)
        return Double(clamped) / 100.0
    }
    
    var body: some View {
        SectionContainer(title: "home_statistics_title") {
            VStack(spacing: layoutMetrics.adaptive(24)) {
                HomeReadinessRingView(
                    readinessPercentage: statistics.readinessPercentage,
                    progress: normalizedProgress
                )

                HomeStatisticsBreakdownView(statistics: statistics)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .accessibilityElement(children: .contain)
    }
}

private extension HomeStatisticsSection {

}

// MARK: - Readiness Ring View
/// Animated circular progress visualization for the readiness percentage.
private struct HomeReadinessRingView: View {
    let readinessPercentage: Int
    let progress: Double
    
    @State private var animatedProgress: Double = 0
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    private var ringSize: CGFloat { layoutMetrics.adaptive(196) }
    private var ringLineWidth: CGFloat { layoutMetrics.adaptive(24) }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: ringLineWidth)
            
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [
                            Color("AppBlueLagoon"),
                            Color("AppBlueLagoon").opacity(0.8),
                            Color("AccentColor")
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.7, dampingFraction: 0.85), value: animatedProgress)
            
            VStack(spacing: layoutMetrics.adaptive(6)) {
                Text("\(readinessPercentage)%")
                    .font(.system(size: layoutMetrics.adaptive(36), weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("home_statistics_caption".localized)
                    .font(.system(.callout, design: .rounded).weight(.semibold))
                    .foregroundColor(Color.secondary.opacity(0.9))
            }
        }
        .frame(width: ringSize, height: ringSize)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("home_statistics_accessibility_label".localized)
        .accessibilityValue(
            String(
                format: "home_statistics_accessibility_value".localized,
                readinessPercentage
            )
        )
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { _, newValue in
            animatedProgress = newValue
        }
    }
}

// MARK: - Statistics Breakdown View
/// Grid that surfaces the spaced-repetition buckets (wrong, familiar, reinforced, mastered).
private struct HomeStatisticsBreakdownView: View {
    let statistics: HomeStatisticsModel
    @Environment(\.layoutMetrics) private var layoutMetrics
    
    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: layoutMetrics.adaptive(16)),
            GridItem(.flexible(), spacing: layoutMetrics.adaptive(16))
        ]
    }
    
    private var entries: [Entry] {
        [
            Entry(
                id: "wrong",
                titleKey: "statistics_wrong_title",
                count: statistics.wrong,
                color: .init(uiColor: .systemRed)
            ),
            Entry(
                id: "familiar",
                titleKey: "statistics_familiar_title",
                count: statistics.familiar,
                color: Color(red: 1.0, green: 0.7, blue: 0.0)
            ),
            Entry(
                id: "reinforced",
                titleKey: "statistics_reinforced_title",
                count: statistics.reinforced,
                color: .init(uiColor: .systemBlue)
            ),
            Entry(
                id: "mastered",
                titleKey: "statistics_mastered_title",
                count: statistics.mastered,
                color: .init(uiColor: .systemGreen)
            )
        ]
    }
    
    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: layoutMetrics.adaptive(16)) {
            ForEach(entries) { entry in
                VStack(spacing: layoutMetrics.adaptive(8)) {
                    Text("\(entry.count)")
                        .font(.system(size: layoutMetrics.adaptive(24), weight: .bold, design: .rounded))
                        .foregroundColor(entry.color)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(entry.titleKey.localized)
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(layoutMetrics.adaptive(14))
                .background(
                    RoundedRectangle(cornerRadius: layoutMetrics.adaptive(20), style: .continuous)
                        .fill(Color(.systemGray6).opacity(0.55))
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(entry.accessibilityLabel)
            }
        }
    }
}

private extension HomeStatisticsBreakdownView {
    struct Entry: Identifiable {
        let id: String
        let titleKey: String
        let count: Int
        let color: Color
        
        var accessibilityLabel: String {
            String(
                format: "%@ – %d",
                titleKey.localized,
                count
            )
        }
    }
}

// MARK: - Preview
#Preview {
    HomeStatisticsSection(
        statistics: HomeStatisticsModel(
            readinessPercentage: 72,
            wrong: 12,
            familiar: 86,
            reinforced: 54,
            mastered: 158,
            totalQuestions: LayoutMetrics.totalFederalQuestions
        )
    )
        .padding()
        .background(Color(.systemBackground))
        .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}

