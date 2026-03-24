import SwiftUI

struct QuizTypingInputView: View {
    @Environment(HapticsService.self) private var hapticsService

    let question: QuizQuestion
    let quizType: QuizType
    let showFeedback: Bool
    let isCorrectAnswer: Bool
    let showAutocomplete: Bool
    let countries: [Country]
    @Binding var typingInput: String
    @Binding var showHint: Bool
    @Binding var showFlagPreview: Bool
    let onSubmit: () -> Void

    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: DesignSystem.Spacing.md)
            promptSection
            Spacer(minLength: DesignSystem.Spacing.lg)
            typingSection
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
        .onAppear { isInputFocused = true }
        .onChange(of: showFeedback) { _, newValue in
            if newValue { isInputFocused = false }
        }
    }
}

// MARK: - Prompt

private extension QuizTypingInputView {
    @ViewBuilder
    var promptSection: some View {
        switch quizType {
        case .flagQuiz:
            flagPrompt
        default:
            textPrompt(question.promptText, subject: question.promptSubject)
        }
    }

    var flagPrompt: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            if let flagCode = question.promptFlag {
                Button { showFlagPreview = true } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(DesignSystem.Color.accent.opacity(0.12))
                            .blur(radius: 24)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)

                        FlagView(countryCode: flagCode, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: .black.opacity(0.45), radius: 22, y: 10)
                            .shadow(color: DesignSystem.Color.accent.opacity(0.15), radius: 12, y: 4)
                    }
                }
                .buttonStyle(.plain)

                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 9))
                    Text("Tap to zoom")
                        .font(DesignSystem.Font.caption2)
                }
                .foregroundStyle(DesignSystem.Color.textTertiary)
            }

            Text(question.promptText)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, DesignSystem.Spacing.xxs)
        }
    }

    func textPrompt(_ text: String, subject: String?) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text(text)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .multilineTextAlignment(.center)

            if let subject {
                Text(subject)
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .lineLimit(3)
                    .padding(.horizontal, DesignSystem.Spacing.xs)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.xl)
    }
}

// MARK: - Typing Input

private extension QuizTypingInputView {
    var typingSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            controlsRow

            if showFeedback, !isCorrectAnswer {
                correctAnswerLabel
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            }

            if showAutocomplete, !filteredSuggestions.isEmpty, isInputFocused, !showFeedback {
                suggestionsList
            }

            inputField
        }
    }

    var filteredSuggestions: [Country] {
        guard showAutocomplete, !typingInput.isEmpty else { return [] }
        let query = typingInput.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
        return countries
            .filter {
                $0.name.lowercased()
                    .folding(options: .diacriticInsensitive, locale: .current)
                    .contains(query)
            }
            .prefix(5)
            .map { $0 }
    }

    var suggestionsList: some View {
        VStack(spacing: 0) {
            ForEach(filteredSuggestions) { country in
                Button {
                    typingInput = country.name
                    isInputFocused = false
                    onSubmit()
                } label: {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        FlagView(countryCode: country.code, height: 20)

                        Text(country.name)
                            .font(DesignSystem.Font.body)
                            .foregroundStyle(DesignSystem.Color.textPrimary)

                        Spacer()
                    }
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }

    var inputField: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            TextField("Type your answer...", text: $typingInput)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .focused($isInputFocused)
                .disabled(showFeedback)
                .onSubmit { onSubmit() }

            inputTrailingContent
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(inputBackground)
        .animation(.easeInOut(duration: 0.3), value: showFeedback)
        .animation(.easeInOut(duration: 0.3), value: isCorrectAnswer)
        .animation(.easeInOut(duration: 0.2), value: isInputFocused)
    }

    @ViewBuilder
    var inputTrailingContent: some View {
        if showFeedback {
            Image(systemName: isCorrectAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(isCorrectAnswer ? DesignSystem.Color.success : DesignSystem.Color.error)
                .transition(.scale.combined(with: .opacity))
        } else if !typingInput.isEmpty {
            Button {
                typingInput = ""
                isInputFocused = true
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(DesignSystem.Font.callout)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .buttonStyle(.plain)
        }
    }

    var inputBackground: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
            .fill(DesignSystem.Color.cardBackground)
            .overlay {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .strokeBorder(inputBorderColor, lineWidth: 2)
            }
    }

    var correctAnswerLabel: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "checkmark")
                .font(DesignSystem.Font.caption2)
            Text(correctAnswerText)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(DesignSystem.Color.success)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(DesignSystem.Color.success.opacity(0.15), in: Capsule())
    }

    var controlsRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            hintButton
            Spacer()
            submitButton
        }
    }

    var hintButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showHint.toggle()
            }
            hapticsService.selection()
        } label: {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: showHint ? "lightbulb.fill" : "lightbulb")
                    .font(DesignSystem.Font.caption)
                Text(showHint ? hintText : "Hint")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.medium)
                    .contentTransition(.opacity)
            }
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .glassEffect(.regular.interactive(), in: .capsule)
        .disabled(showFeedback)
        .opacity(showFeedback ? 0.4 : 1)
    }

    var submitButton: some View {
        Button { onSubmit() } label: {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Text("Submit")
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.bold)
                Image(systemName: "arrow.right")
                    .font(DesignSystem.Font.caption)
            }
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .glassEffect(.regular.interactive(), in: .capsule)
        .disabled(showFeedback || typingInput.trimmingCharacters(in: .whitespaces).isEmpty)
    }
}

// MARK: - Helpers

private extension QuizTypingInputView {
    var inputBorderColor: Color {
        guard showFeedback else {
            return isInputFocused
                ? DesignSystem.Color.accent.opacity(0.5)
                : DesignSystem.Color.accent.opacity(0.2)
        }
        return isCorrectAnswer ? DesignSystem.Color.success : DesignSystem.Color.error
    }

    var correctAnswerText: String {
        if let correctOption = question.options.first(where: { $0.id == question.correctOptionID }),
           let text = correctOption.text {
            return text
        }
        if quizType == .capitalQuiz {
            return question.correctCountry.capital
        }
        return question.correctCountry.name
    }

    var hintText: String {
        let answer = correctAnswerText
        guard answer.count >= 2 else { return answer }
        return String(answer.prefix(2)) + "..."
    }
}
