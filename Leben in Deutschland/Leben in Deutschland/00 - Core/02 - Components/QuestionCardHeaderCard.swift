//
//  QuestionCardHeaderCard.swift
//  Leben in Deutschland
//
//  Header card for question cards (Learning, Spaced Repetition, Test Session, Favorites, Test Answers).
//  Provides back button, optional title, progress bar, question ID with report, and customizable action bar.
//

import SwiftUI

// MARK: - Question Card Header Card
struct QuestionCardHeaderCard<ActionContent: View>: View {
    /// Back button action. When nil, back row is hidden.
    var onBackTapped: (() -> Void)?
    /// Back icon: .backward (chevron.backward) or .down (chevron.down).
    var backIcon: QuestionCardBackIcon = .backward
    var showPremiumButton: Bool = false
    var gradient: LiquidGlassGradient = .blue
    var onPremiumTap: (() -> Void)?
    /// Optional title (e.g. subcategory name, "Your answers").
    var title: String?
    /// Optional progress (answered, total).
    var progress: (answered: Int, total: Int)?
    /// Question ID for label. When nil, question row is hidden.
    var questionId: String?
    var onReportTapped: (() -> Void)?
    @ViewBuilder var trailingActions: () -> ActionContent

    @Environment(\.layoutMetrics) private var layoutMetrics

    private var contentSpacing: CGFloat { layoutMetrics.adaptive(16) }
    private var progressBarHeight: CGFloat { layoutMetrics.adaptive(8) }

    var body: some View {
        headerCardContent
            .padding(.vertical, layoutMetrics.adaptive(18))
            .padding(.horizontal, layoutMetrics.adaptive(20))
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LiquidGlassBackground(gradient: gradient))
            .clipShape(RoundedRectangle(cornerRadius: layoutMetrics.adaptive(32), style: .continuous))
            .overlay(HeaderBorderOverlay())
            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
            .padding(.horizontal)
            .padding(.top, layoutMetrics.adaptive(8))
    }

    private var headerCardContent: some View {
        VStack(alignment: .leading, spacing: contentSpacing) {
            if onBackTapped != nil {
                backButtonRow
            }

            if title != nil {
                titleSection
            }

            if progress != nil {
                progressBar
            }

            if questionId != nil {
                questionHeaderRow
            }
        }
    }

    private var backButtonRow: some View {
        HStack {
            Button(action: {
                HapticManager.shared.lightImpact()
                onBackTapped?()
            }) {
                Image(systemName: backIcon.systemName)
                    .font(.system(size: layoutMetrics.adaptive(20), weight: .semibold))
                    .foregroundColor(.white)
                    .padding(layoutMetrics.adaptive(10))
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.18))
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("back_button_accessibility_label".localized)

            Spacer()

            if showPremiumButton {
                PremiumCrownButton(action: { onPremiumTap?() }, color: .white)
            }
        }
    }

    @ViewBuilder
    private var titleSection: some View {
        if let title {
            Text(title)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
    }

    @ViewBuilder
    private var progressBar: some View {
        if let progress {
            ProgressView(
                value: Double(progress.answered),
                total: max(Double(progress.total), 1)
            )
            .progressViewStyle(LinearProgressViewStyle(tint: Color(.systemGray6)))
            .frame(height: progressBarHeight)
            .clipShape(Capsule())
        }
    }

    private var questionHeaderRow: some View {
        HStack {
            questionLabelView
            Spacer()
            trailingActions()
        }
    }

    @ViewBuilder
    private var questionLabelView: some View {
        if let questionId {
            HStack(spacing: 8) {
                Text("question_label".localized + " \(questionId)")
                    .font(.system(.headline, design: .rounded).weight(.semibold))
                    .foregroundColor(.white)
                    .accessibilityLabel("question_label".localized + " " + questionId)

                if let onReportTapped {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        onReportTapped()
                    }) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }
}

// MARK: - Back Icon
enum QuestionCardBackIcon {
    case backward
    case down

    var systemName: String {
        switch self {
        case .backward: return "chevron.backward"
        case .down: return "chevron.down"
        }
    }
}

// MARK: - Convenience initializer for empty actions
extension QuestionCardHeaderCard where ActionContent == EmptyView {
    init(
        onBackTapped: (() -> Void)? = nil,
        backIcon: QuestionCardBackIcon = .backward,
        showPremiumButton: Bool = false,
        gradient: LiquidGlassGradient = .blue,
        onPremiumTap: (() -> Void)? = nil,
        title: String? = nil,
        progress: (answered: Int, total: Int)? = nil,
        questionId: String? = nil,
        onReportTapped: (() -> Void)? = nil
    ) {
        self.onBackTapped = onBackTapped
        self.backIcon = backIcon
        self.showPremiumButton = showPremiumButton
        self.gradient = gradient
        self.onPremiumTap = onPremiumTap
        self.title = title
        self.progress = progress
        self.questionId = questionId
        self.onReportTapped = onReportTapped
        self.trailingActions = { EmptyView() }
    }
}

// MARK: - Preview
#Preview {
    QuestionCardHeaderCard(
        onBackTapped: {},
        showPremiumButton: true,
        onPremiumTap: {},
        title: "Politics in Democracy",
        progress: (5, 10),
        questionId: "101",
        onReportTapped: {},
        trailingActions: {
            HStack(spacing: 8) {
                Text("Actions")
            }
        }
    )
    .environmentObject(LanguageManager())
    .layoutMetrics(LayoutMetrics.make(for: CGSize(width: 390, height: 844)))
}
