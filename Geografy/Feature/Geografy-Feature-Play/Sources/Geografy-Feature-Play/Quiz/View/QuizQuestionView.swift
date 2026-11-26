import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

public struct QuizQuestionView: View {
    // MARK: - Properties
    public let question: QuizQuestion
    public let quizType: QuizType
    public let selectedOptionID: UUID?
    public let correctOptionID: UUID
    public let showFeedback: Bool
    @Binding var showFlagPreview: Bool
    public let onSelectOption: (UUID) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var promptVisible = false

    // MARK: - Body
    public var body: some View {
        mainContent
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.md)
            .onAppear { triggerEntrance() }
    }
}

// MARK: - Subviews
private extension QuizQuestionView {
    /// The question starts right under the progress bar, at the same place for every question, and the answers sit
    /// at the bottom; a longer question or its explanation grows down, never moving where it starts.
    var mainContent: some View {
        VStack(spacing: 0) {
            // Only the prompt slides to the next question; the answers stay put and rise in anew.
            promptSection
                .padding(.top, DesignSystem.Spacing.md)
                .opacity(promptVisible ? 1 : 0)
                .scaleEffect(promptVisible || reduceMotion ? 1 : 0.94)
                .animation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.8), value: promptVisible)
                .id(question.id)
                .transition(.nextQuestion(reduceMotion: reduceMotion))
            Spacer(minLength: DesignSystem.Spacing.lg)
            optionsSection
        }
    }
}

// MARK: - Entrance
private extension QuizQuestionView {
    func triggerEntrance() {
        guard !reduceMotion else {
            promptVisible = true
            return
        }
        promptVisible = false
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.05)) {
            promptVisible = true
        }
    }
}

// MARK: - Prompt
private extension QuizQuestionView {
    @ViewBuilder
    var promptSection: some View {
        switch quizType {
        case .flagQuiz:
            flagPrompt
        case .reverseFlag:
            textPrompt(question.promptText, subject: question.promptSubject)
        case .capitalQuiz, .reverseCapital, .worldRankings, .nationalSymbols, .landmarks, .nicknames, .trueOrFalse,
             .neighbors, .mysteryCountry:
            textPrompt(question.promptText, subject: question.promptSubject)
        }
    }

    var flagPrompt: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            if let flagCode = question.promptFlag {
                Button { showFlagPreview = true } label: {
                    ZStack {
                        if !reduceTransparency {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                                .fill(DesignSystem.Color.iconSecondary.opacity(DesignSystem.Opacity.tint))
                                .blur(radius: 24)
                                .padding(.horizontal, DesignSystem.Spacing.md)
                                .padding(.vertical, DesignSystem.Spacing.xs)
                        }

                        FlagView(countryCode: flagCode, height: 200)
                            .clipShape(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                            )
                            .geoShadow(.elevated)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Mystery flag")
                .accessibilityHint("Opens the flag full screen")

                zoomHint
            }

            Text(question.promptText)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, DesignSystem.Spacing.xxs)
        }
    }

    var zoomHint: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "arrow.up.left.and.arrow.down.right")
                .font(DesignSystem.Font.nano)
            Text("Tap to zoom")
                .font(DesignSystem.Font.caption2)
        }
        .foregroundStyle(DesignSystem.Color.textSecondary)
        .accessibilityHidden(true)
    }

    func textPrompt(_ text: String, subject: String?) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text(text)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)

            if let subject {
                Text(subject)
                    .font(DesignSystem.Font.roundedHeadline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 3)
                    .accessibilityAddTraits(.isHeader)
                    .padding(.horizontal, DesignSystem.Spacing.xs)
            }

            if !question.promptDetails.isEmpty {
                promptDetailsList
            }

            if showFeedback, let explanation = question.explanation {
                Text(explanation)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: showFeedback)
    }

    var promptDetailsList: some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                ForEach(question.promptDetails, id: \.self) { detail in
                    Text(detail)
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Options
private extension QuizQuestionView {
    var optionsSection: some View {
        QuizOptionList(
            options: question.options,
            layout: quizType == .reverseFlag ? .flagGrid : .list,
            selectedOptionID: selectedOptionID,
            correctOptionID: correctOptionID,
            showFeedback: showFeedback,
            onSelect: onSelectOption
        )
    }
}
