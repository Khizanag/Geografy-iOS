import SwiftUI

struct QuizSpellingBeeView: View {
    let question: QuizQuestion
    let quizType: QuizType
    let showFeedback: Bool
    let isCorrectAnswer: Bool
    @Binding var typingInput: String
    @Binding var showFlagPreview: Bool
    let onSubmit: () -> Void

    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: DesignSystem.Spacing.md)

            promptSection

            Spacer(minLength: DesignSystem.Spacing.md)

            letterGridSection

            if !showFeedback {
                skipButton
            }

            Spacer(minLength: DesignSystem.Spacing.sm)

            inputSection
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .onAppear { isInputFocused = true }
        .onChange(of: showFeedback) { _, newValue in
            if newValue { isInputFocused = false }
        }
        .onChange(of: typingInput) { _, _ in
            checkAutoSubmit()
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
                        .font(.system(size: 28, weight: .black, design: .rounded))
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
            typingInput = correctAnswerText
            onSubmit()
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
                isRevealed: showFeedback
            )
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Input

private extension QuizSpellingBeeView {
    var inputSection: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            TextField("Type answer...", text: $typingInput)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)
                .focused($isInputFocused)
                .disabled(showFeedback)
                .onSubmit { onSubmit() }

            if !typingInput.isEmpty, !showFeedback {
                Button { typingInput = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(DesignSystem.Font.callout)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
                .buttonStyle(.plain)
            }

            if showFeedback {
                Image(systemName: isCorrectAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(isCorrectAnswer ? DesignSystem.Color.success : DesignSystem.Color.error)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .strokeBorder(inputBorderColor, lineWidth: 2)
        )
    }

    var inputBorderColor: Color {
        guard showFeedback else {
            return isInputFocused
                ? DesignSystem.Color.accent.opacity(0.5)
                : DesignSystem.Color.accent.opacity(0.2)
        }
        return isCorrectAnswer ? DesignSystem.Color.success : DesignSystem.Color.error
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
