import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

public struct QuizSpellingBeeView: View {
    public let question: QuizQuestion
    public let quizType: QuizType
    public let showFeedback: Bool
    public let isCorrectAnswer: Bool
    public let wasSkipped: Bool
    @Binding var typingInput: String
    @Binding var showFlagPreview: Bool
    public let onSubmit: () -> Void
    public let onSkip: () -> Void

    @FocusState private var isInputFocused: Bool

    public var body: some View {
        mainContent
            .padding(.horizontal, DesignSystem.Spacing.md)
            .onAppear { isInputFocused = true }
            .onChange(of: typingInput) { _, _ in
                checkAutoSubmit()
            }
    }
}

// MARK: - Subviews
private extension QuizSpellingBeeView {
    var mainContent: some View {
        VStack(spacing: 0) {
            Spacer(minLength: DesignSystem.Spacing.md)

            promptSection

            Spacer(minLength: DesignSystem.Spacing.md)

            if showFeedback {
                feedbackIcon
            }

            letterGridSection

            if !showFeedback {
                skipButton
            }

            Spacer(minLength: DesignSystem.Spacing.sm)

            hiddenTextField
        }
    }
}

// MARK: - Prompt
private extension QuizSpellingBeeView {
    @ViewBuilder
    var promptSection: some View {
        if quizType == .flagQuiz, let flagCode = question.promptFlag {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Button { showFlagPreview = true } label: {
                    FlagView(countryCode: flagCode, height: 120)
                        .geoShadow(.elevated)
                }
                .buttonStyle(.plain)

                Text(question.promptText)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        } else {
            VStack(spacing: DesignSystem.Spacing.sm) {
                if let subject = question.promptSubject {
                    Text(subject)
                        .font(DesignSystem.Font.roundedBody)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .lineLimit(2)
                }

                Text(question.promptText)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    var skipButton: some View {
        Button {
            onSkip()
        } label: {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: "forward.fill")
                    .font(DesignSystem.Font.caption)

                Text("Skip")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(DesignSystem.Color.textSecondary)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xxs)
        }
        .glassEffect(.regular.interactive(), in: .capsule)
    }
}

// MARK: - Letter Grid
private extension QuizSpellingBeeView {
    var letterGridSection: some View {
        CardView {
            LetterGridView(
                targetText: correctAnswerText,
                typedText: typingInput,
                isRevealed: showFeedback,
                wasSkipped: wasSkipped
            )
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Input
private extension QuizSpellingBeeView {
    var feedbackIcon: some View {
        Group {
            if wasSkipped {
                Image(systemName: "forward.fill")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            } else {
                Image(systemName: isCorrectAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(
                        isCorrectAnswer
                            ? DesignSystem.Color.success
                            : DesignSystem.Color.error
                    )
            }
        }
        .padding(.bottom, DesignSystem.Spacing.sm)
        .transition(.scale.combined(with: .opacity))
    }

    var hiddenTextField: some View {
        TextField("", text: $typingInput)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.characters)
            .focused($isInputFocused)
            .disabled(showFeedback)
            .onSubmit { onSubmit() }
            .frame(width: 1, height: 1)
            .opacity(0)
    }
}

// MARK: - Helpers
private extension QuizSpellingBeeView {
    var correctAnswerText: String {
        if let correctOption = question.options.first(where: { $0.id == question.correctOptionID }),
           let text = correctOption.text {
            return text
        }
        return question.correctCountry.name
    }

    func checkAutoSubmit() {
        guard !showFeedback else { return }
        if LetterGridHelper.lettersMatch(typed: typingInput, target: correctAnswerText) {
            onSubmit()
        }
    }
}
