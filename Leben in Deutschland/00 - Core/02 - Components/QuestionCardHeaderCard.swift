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
    /// When set, the question ID label is tappable (e.g. jump-to-question in All Questions).
    var onQuestionIdTapped: (() -> Void)? = nil
    /// When true, shows decorative Pro badge. Hidden for free users.
    var showProBadge: Bool = false
    var isProUser: Bool = false
    /// Legacy: not used when badge is decorative.
    var onProTap: (() -> Void)? = nil
    /// Renders trailing actions in a top row inside the header when back uses the system nav bar.
    var showsTopToolbar: Bool = false
    /// When true, `trailingActions` appear on the question ID row (right) instead of the top toolbar.
    var trailingActionsOnQuestionRow: Bool = false
    @ViewBuilder var trailingActions: () -> ActionContent

    @Environment(\.layoutMetrics) private var layoutMetrics

    /// Inset above the first row, below the last row, and between toolbar and progress.
    private var headerVerticalSpacing: CGFloat { layoutMetrics.adaptive(20) }
    /// Slightly tighter gap between the progress bar row and ID/title row.
    private var headerProgressToContentSpacing: CGFloat { layoutMetrics.adaptive(16) }
    private var progressBarHeight: CGFloat { layoutMetrics.adaptive(8) }
    /// Matches ~title2 line height so the thin progress bar row balances the ID/title row.
    private var progressRowMinHeight: CGFloat { layoutMetrics.adaptive(28) }

    init(
        onBackTapped: (() -> Void)? = nil,
        backIcon: QuestionCardBackIcon = .backward,
        gradient: LiquidGlassGradient = .blue,
        title: String? = nil,
        titleInBackRow: Bool = false,
        progress: (answered: Int, total: Int)? = nil,
        questionId: String? = nil,
        onReportTapped: (() -> Void)? = nil,
        onQuestionIdTapped: (() -> Void)? = nil,
        showProBadge: Bool = false,
        isProUser: Bool = false,
        onProTap: (() -> Void)? = nil,
        showsTopToolbar: Bool = false,
        trailingActionsOnQuestionRow: Bool = false,
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
        self.onQuestionIdTapped = onQuestionIdTapped
        self.showProBadge = showProBadge
        self.isProUser = isProUser
        self.onProTap = onProTap
        self.showsTopToolbar = showsTopToolbar
        self.trailingActionsOnQuestionRow = trailingActionsOnQuestionRow
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
        onQuestionIdTapped: (() -> Void)? = nil,
        showProBadge: Bool = false,
        isPro: Bool,
        onProTap: (() -> Void)? = nil,
        showsTopToolbar: Bool = false,
        trailingActionsOnQuestionRow: Bool = false,
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
            onQuestionIdTapped: onQuestionIdTapped,
            showProBadge: showProBadge,
            isProUser: isPro,
            onProTap: onProTap,
            showsTopToolbar: showsTopToolbar,
            trailingActionsOnQuestionRow: trailingActionsOnQuestionRow,
            trailingActions: trailingActions
        )
    }

    var body: some View {
        headerCardContent
            .padding(.horizontal, layoutMetrics.adaptive(20))
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LiquidGlassBackground(gradient: gradient))
            .clipShape(RoundedRectangle(cornerRadius: layoutMetrics.adaptive(32), style: .continuous))
            .overlay(HeaderBorderOverlay())
            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
            .padding(.horizontal)
    }

    private var headerCardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            if shouldShowTopToolbar {
                topToolbarRow
                    .padding(.bottom, hasContentBelowToolbar ? headerVerticalSpacing : 0)
            }

            if progress != nil {
                progressBar
                    .padding(.bottom, hasSecondaryContentRow ? headerProgressToContentSpacing : 0)
            }

            if title != nil, !titleInBackRow, questionId != nil {
                titleAndQuestionRow
            } else if title != nil, !titleInBackRow {
                titleSection
            } else if questionId != nil {
                questionHeaderRow
            }
        }
        .padding(.vertical, headerVerticalSpacing)
    }

    private var hasSecondaryContentRow: Bool {
        (title != nil && !titleInBackRow) || questionId != nil
    }

    private var hasContentBelowToolbar: Bool {
        progress != nil || hasSecondaryContentRow
    }

    private var shouldShowTopToolbar: Bool {
        titleInBackRow
            || (showProBadge && isProUser)
            || (showsTopToolbar && !trailingActionsOnQuestionRow)
    }

    private var showsTrailingActionsOnQuestionRow: Bool {
        trailingActionsOnQuestionRow && questionId != nil
    }

    /// Top row inside header card: title (optional) | Spacer | pro badge | trailing actions.
    private var topToolbarRow: some View {
        HStack {
            if titleInBackRow, let title {
                Text(title)
                    .font(.system(.title, weight: .regular).width(.condensed))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }

            Spacer()

            if showProBadge, isProUser {
                ProBadge(color: .white)
            }

            if !trailingActionsOnQuestionRow {
                trailingActions()
            }
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
            .frame(maxWidth: .infinity, minHeight: progressRowMinHeight, alignment: .center)
        }
    }

    private var questionHeaderRow: some View {
        HStack(alignment: .bottom) {
            questionLabelView
            Spacer(minLength: 8)
            if showsTrailingActionsOnQuestionRow {
                trailingActions()
            }
        }
    }

    @ViewBuilder
    private var questionLabelView: some View {
        if let questionId {
            HStack(spacing: 8) {
                questionIdLabel(questionId: questionId)

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

    @ViewBuilder
    private func questionIdLabel(questionId: String) -> some View {
        let label = Text("question_label".localized + " \(questionId)")
            .font(.system(.title2, weight: .light).width(.compressed))
            .foregroundColor(.white)

        if let onQuestionIdTapped {
            Button {
                HapticManager.shared.lightImpact()
                onQuestionIdTapped()
            } label: {
                label
            }
            .buttonStyle(.plain)
            .accessibilityLabel("question_label".localized + " " + questionId)
            .accessibilityHint("all_questions_jump_question_id_hint".localized)
            .accessibilityAddTraits(.isButton)
        } else {
            label
                .accessibilityLabel("question_label".localized + " " + questionId)
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
