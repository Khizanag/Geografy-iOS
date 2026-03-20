import SwiftUI

struct QuizQuestionView: View {
    let question: QuizQuestion
    let quizType: QuizType
    let selectedOptionID: UUID?
    let correctOptionID: UUID
    let showFeedback: Bool
    let onSelectOption: (UUID) -> Void

    @State private var showFlagPreview = false

    var body: some View {
        VStack {
            Spacer()
            promptSection
            Spacer()
            optionsSection
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
        .overlay {
            if showFlagPreview, let flagCode = question.promptFlag {
                ZoomableFlagView(countryCode: flagCode) {
                    showFlagPreview = false
                }
            }
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
        case .capitalQuiz, .reverseFlag, .reverseCapital, .populationOrder, .areaOrder:
            textPrompt(question.promptText)
        }
    }

    var flagPrompt: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            if let flagCode = question.promptFlag {
                Button { showFlagPreview = true } label: {
                    FlagView(countryCode: flagCode, height: DesignSystem.Size.hero * 1.5)
                        .shadow(radius: DesignSystem.Spacing.xs)
                }
                .buttonStyle(.plain)
            }

            Text(question.promptText)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    func textPrompt(_ text: String) -> some View {
        Text(text)
            .font(DesignSystem.Font.title)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .multilineTextAlignment(.center)
            .padding(.vertical, DesignSystem.Spacing.lg)
    }
}

// MARK: - Options

private extension QuizQuestionView {
    @ViewBuilder
    var optionsSection: some View {
        if quizType == .reverseFlag {
            flagOptionsGrid
        } else {
            textOptionsList
        }
    }

    var textOptionsList: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(question.options) { option in
                QuizOptionButton(
                    text: option.text,
                    flagCode: nil,
                    state: optionState(for: option),
                    action: { onSelectOption(option.id) }
                )
            }
        }
    }

    var flagOptionsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
            ],
            spacing: DesignSystem.Spacing.sm
        ) {
            ForEach(question.options) { option in
                QuizOptionButton(
                    text: nil,
                    flagCode: option.flagCode,
                    state: optionState(for: option),
                    action: { onSelectOption(option.id) }
                )
            }
        }
    }
}

// MARK: - Helpers

private extension QuizQuestionView {
    func optionState(for option: QuizOption) -> QuizOptionButton.OptionState {
        guard showFeedback else {
            if selectedOptionID == option.id {
                return .disabled
            }
            return .default
        }

        if option.id == correctOptionID {
            return .correct
        }
        if option.id == selectedOptionID, selectedOptionID != correctOptionID {
            return .incorrect
        }
        return .disabled
    }
}
