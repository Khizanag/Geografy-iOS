import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Feature_Quiz
import SwiftUI

public struct MultiplayerRoundView: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    public let question: QuizQuestion
    public let quizType: QuizType
    public let opponentIsThinking: Bool
    public let opponentHasAnswered: Bool
    public let selectedOptionID: UUID?
    public let showFeedback: Bool
    public let opponentSelectedOptionID: UUID?
    public let onSelectOption: (UUID) -> Void

    // MARK: - Body
    public var body: some View {
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
                    .accessibilityLabel("Mystery flag")
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
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                    .minimumScaleFactor(0.8)
                    .accessibilityAddTraits(.isHeader)
            } else {
                Text(question.promptText)
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                    .minimumScaleFactor(0.8)
                    .accessibilityAddTraits(.isHeader)
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
                    .accessibilityHidden(true)
                Text("Opponent answered")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            } else if opponentIsThinking {
                thinkingDots
                    .accessibilityHidden(true)
                Text("Opponent thinking")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: opponentHasAnswered)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: opponentIsThinking)
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
                            ? nil
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
                .accessibilityLabel(option.text ?? "Flag \(index + 1)")
                .accessibilityValue(optionAccessibilityValue(for: option))
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
            .accessibilityHidden(true)
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

    func optionAccessibilityValue(for option: QuizOption) -> String {
        var parts: [String] = []
        switch optionState(for: option) {
        case .correct: parts.append("Correct answer")
        case .incorrect: parts.append("Your answer, incorrect")
        case .default, .disabled: break
        }
        if showFeedback, opponentSelectedOptionID == option.id {
            parts.append("Opponent's pick")
        }
        return parts.joined(separator: ", ")
    }
}
