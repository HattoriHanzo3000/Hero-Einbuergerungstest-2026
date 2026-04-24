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
    var gradient: LiquidGlassGradient = .blue
    /// Optional title (e.g. subcategory name, "Your answers").
    var title: String?
    /// When true, title is shown on the same row as the back button, right-aligned (no separate title block).
    var titleInBackRow: Bool = false
    /// Optional progress (answered, total).
    var progress: (answered: Int, total: Int)?
    /// Question ID for label. When nil, question row is hidden.
    var questionId: String?
    var onReportTapped: (() -> Void)?
    /// When true, shows decorative Pro badge. Hidden for free users.
    var showProBadge: Bool = false
    var isProUser: Bool = false
    /// Legacy: not used when badge is decorative.
    var onProTap: (() -> Void)? = nil
    @ViewBuilder var trailingActions: () -> ActionContent

    @Environment(\.layoutMetrics) private var layoutMetrics

    private var contentSpacing: CGFloat { layoutMetrics.adaptive(16) }
    private var progressBarHeight: CGFloat { layoutMetrics.adaptive(8) }

    init(
        onBackTapped: (() -> Void)? = nil,
        backIcon: QuestionCardBackIcon = .backward,
        gradient: LiquidGlassGradient = .blue,
        title: String? = nil,
        titleInBackRow: Bool = false,
        progress: (answered: Int, total: Int)? = nil,
        questionId: String? = nil,
        onReportTapped: (() -> Void)? = nil,
        showProBadge: Bool = false,
        isProUser: Bool = false,
        onProTap: (() -> Void)? = nil,
        @ViewBuilder trailingActions: @escaping () -> ActionContent
    ) {
        self.onBackTapped = onBackTapped
        self.backIcon = backIcon
        self.gradient = gradient
        self.title = title
        self.titleInBackRow = titleInBackRow
        self.progress = progress
        self.questionId = questionId
        self.onReportTapped = onReportTapped
        self.showProBadge = showProBadge
        self.isProUser = isProUser
        self.onProTap = onProTap
        self.trailingActions = trailingActions
    }

    init(
        onBackTapped: (() -> Void)? = nil,
        backIcon: QuestionCardBackIcon = .backward,
        gradient: LiquidGlassGradient = .blue,
        title: String? = nil,
        titleInBackRow: Bool = false,
        progress: (answered: Int, total: Int)? = nil,
        questionId: String? = nil,
        onReportTapped: (() -> Void)? = nil,
        showProBadge: Bool = false,
        isPro: Bool,
        onProTap: (() -> Void)? = nil,
        @ViewBuilder trailingActions: @escaping () -> ActionContent
    ) {
        self.init(
            onBackTapped: onBackTapped,
            backIcon: backIcon,
            gradient: gradient,
            title: title,
            titleInBackRow: titleInBackRow,
            progress: progress,
            questionId: questionId,
            onReportTapped: onReportTapped,
            showProBadge: showProBadge,
            isProUser: isPro,
            onProTap: onProTap,
            trailingActions: trailingActions
        )
    }

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
    }

    private var headerCardContent: some View {
        VStack(alignment: .leading, spacing: contentSpacing) {
            if onBackTapped != nil {
                backButtonRow
            }

            if progress != nil {
                progressBar
            }

            if title != nil, !titleInBackRow, questionId != nil {
                titleAndQuestionRow
            } else if title != nil, !titleInBackRow {
                titleSection
            } else if questionId != nil {
                questionHeaderRow
            }
        }
    }

    /// Top row: back (left) | title (optional) | Spacer | pro (optional) | action buttons (right).
    private var backButtonRow: some View {
        HStack {
            Button(action: {
                HapticManager.shared.lightImpact()
                onBackTapped?()
            }) {
                Image(systemName: backIcon.systemName)
                    .font(.system(size: layoutMetrics.adaptive(20), weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: layoutMetrics.adaptive(40), height: layoutMetrics.adaptive(40))
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.18))
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("back_button_accessibility_label".localized)

            if titleInBackRow, let title {
                Text(title)
                    .font(.system(.title, weight: .regular).width(.condensed))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }

            Spacer()

            if showProBadge, isProUser {
                ProBadge(color: .white)
            }

            trailingActions()
        }
    }

    @ViewBuilder
    private var titleSection: some View {
        if let title {
            Text(title)
                .font(.system(.title, weight: .regular).width(.condensed))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
    }

    /// Question ID + flag (left) | category title (right) on same row.
    @ViewBuilder
    private var titleAndQuestionRow: some View {
        if let title, questionId != nil {
            HStack {
                questionLabelView
                Spacer()
                Text(title)
                    .font(.system(.title2, weight: .regular).width(.condensed))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
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
        }
    }

    @ViewBuilder
    private var questionLabelView: some View {
        if let questionId {
            HStack(spacing: 8) {
                Text("question_label".localized + " \(questionId)")
                    .font(.system(.title2, weight: .light).width(.compressed))
                    .foregroundColor(.white)
                    .accessibilityLabel("question_label".localized + " " + questionId)

                if let onReportTapped {
                    Button(action: {
                        HapticManager.shared.lightImpact()
                        onReportTapped()
                    }) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
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
        gradient: LiquidGlassGradient = .blue,
        title: String? = nil,
        progress: (answered: Int, total: Int)? = nil,
        questionId: String? = nil,
        onReportTapped: (() -> Void)? = nil,
        showProBadge: Bool = false,
        isProUser: Bool = false,
        onProTap: (() -> Void)? = nil
    ) {
        self.onBackTapped = onBackTapped
        self.backIcon = backIcon
        self.gradient = gradient
        self.title = title
        self.progress = progress
        self.questionId = questionId
        self.onReportTapped = onReportTapped
        self.showProBadge = showProBadge
        self.isProUser = isProUser
        self.onProTap = onProTap
        self.trailingActions = { EmptyView() }
    }

    init(
        onBackTapped: (() -> Void)? = nil,
        backIcon: QuestionCardBackIcon = .backward,
        gradient: LiquidGlassGradient = .blue,
        title: String? = nil,
        progress: (answered: Int, total: Int)? = nil,
        questionId: String? = nil,
        onReportTapped: (() -> Void)? = nil,
        showProButton: Bool = false,
        isPro: Bool = false,
        onProTap: (() -> Void)? = nil
    ) {
        self.init(
            onBackTapped: onBackTapped,
            backIcon: backIcon,
            gradient: gradient,
            title: title,
            progress: progress,
            questionId: questionId,
            onReportTapped: onReportTapped,
            showProBadge: showProButton,
            isProUser: isPro,
            onProTap: onProTap
        )
    }
}

// MARK: - Preview
#Preview {
    QuestionCardHeaderCard(
        onBackTapped: {},
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
