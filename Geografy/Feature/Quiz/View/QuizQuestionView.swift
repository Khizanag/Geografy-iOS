import SwiftUI

struct QuizQuestionView: View {
    let question: QuizQuestion
    let quizType: QuizType
    let selectedOptionID: UUID?
    let correctOptionID: UUID
    let showFeedback: Bool
    let onSelectOption: (UUID) -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            promptSection
            optionsSection
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
}

// MARK: - Subviews

private extension QuizQuestionView {
    @ViewBuilder
    var promptSection: some View {
        switch quizType {
        case .flagQuiz:
            flagPrompt
        case .capitalQuiz:
            textPrompt(question.promptText)
        case .reverseFlag:
            textPrompt(question.promptText)
        case .reverseCapital:
            textPrompt(question.promptText)
        case .populationOrder, .areaOrder:
            textPrompt(question.promptText)
        }
    }

    var flagPrompt: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            if let flagCode = question.promptFlag {
                FlagView(countryCode: flagCode, height: DesignSystem.Size.hero)
                    .shadow(radius: DesignSystem.Spacing.xs)
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
