import SwiftUI
import GeografyDesign

struct MultiplayerRoundView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let question: QuizQuestion
    let quizType: QuizType
    let opponentIsThinking: Bool
    let opponentHasAnswered: Bool
    let selectedOptionID: UUID?
    let showFeedback: Bool
    let opponentSelectedOptionID: UUID?
    let onSelectOption: (UUID) -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            questionPrompt
            optionsGrid
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
    }
}

// MARK: - Subviews
private extension MultiplayerRoundView {
    var questionPrompt: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            if let promptFlag = question.promptFlag {
                FlagView(countryCode: promptFlag, height: 80)
            }

            if let subject = question.promptSubject {
                Text(question.promptText)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)

                Text(subject)
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            } else {
                Text(question.promptText)
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }

            opponentStatusIndicator
        }
    }

    var opponentStatusIndicator: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            if opponentHasAnswered {
                Image(systemName: "checkmark.circle.fill")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.success)
                Text("Opponent answered")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            } else if opponentIsThinking {
                thinkingDots
                Text("Opponent thinking")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: opponentHasAnswered)
        .animation(.easeInOut(duration: 0.3), value: opponentIsThinking)
    }

    var thinkingDots: some View {
        HStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(DesignSystem.Color.textTertiary)
                    .frame(width: 4, height: 4)
                    .opacity(opponentIsThinking ? 1 : 0.3)
                    .animation(
                        reduceMotion
                            ? .default
                            : .easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                        value: opponentIsThinking
                    )
            }
        }
    }

    var optionsGrid: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(
                Array(question.options.enumerated()),
                id: \.element.id
            ) { index, option in
                QuizOptionButton(
                    text: option.text,
                    flagCode: option.flagCode,
                    state: optionState(for: option),
                    index: index
                ) {
                    onSelectOption(option.id)
                }
                .overlay(alignment: .trailing) {
                    if showFeedback,
                       opponentSelectedOptionID == option.id {
                        opponentMarker
                            .padding(.trailing, DesignSystem.Spacing.md)
                    }
                }
            }
        }
    }

    var opponentMarker: some View {
        Text("OPP")
            .font(DesignSystem.Font.nano.bold())
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.xxs)
            .padding(.vertical, 2)
            .background(DesignSystem.Color.purple, in: Capsule())
    }
}

// MARK: - Helpers
private extension MultiplayerRoundView {
    func optionState(for option: QuizOption) -> QuizOptionButton.OptionState {
        guard showFeedback else {
            return selectedOptionID != nil ? .disabled : .default
        }
        if option.id == question.correctOptionID { return .correct }
        if selectedOptionID == option.id { return .incorrect }
        return .disabled
    }
}
