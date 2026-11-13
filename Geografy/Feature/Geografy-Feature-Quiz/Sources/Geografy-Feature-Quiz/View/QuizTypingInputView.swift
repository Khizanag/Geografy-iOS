import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct QuizTypingInputView: View {
    // MARK: - Properties
    @Environment(HapticsService.self) private var hapticsService

    public let question: QuizQuestion
    public let quizType: QuizType
    public let showFeedback: Bool
    public let isCorrectAnswer: Bool
    public let showAutocomplete: Bool
    public let countries: [Country]
    @Binding var typingInput: String
    @Binding var showHint: Bool
    @Binding var showFlagPreview: Bool
    public let onSubmit: () -> Void

    @FocusState private var isInputFocused: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // MARK: - Body
    public var body: some View {
        mainContent
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.md)
            .onAppear { isInputFocused = true }
            .onChange(of: showFeedback) { _, newValue in
                if newValue { isInputFocused = false }
            }
    }
}

// MARK: - Subviews
private extension QuizTypingInputView {
    var mainContent: some View {
        VStack(spacing: 0) {
            Spacer(minLength: DesignSystem.Spacing.md)
            promptSection
            Spacer(minLength: DesignSystem.Spacing.lg)
            typingSection
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
                        if !reduceTransparency {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                                .fill(DesignSystem.Color.accent.opacity(0.12))
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
                .font(DesignSystem.Font.subheadline)
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
                    .transition(reduceMotion ? .opacity : .scale(scale: 0.9).combined(with: .opacity))
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
        CardView(cornerRadius: DesignSystem.CornerRadius.medium) {
            VStack(spacing: 0) {
                ForEach(filteredSuggestions) { country in
                    Button {
                        typingInput = country.name
                        isInputFocused = false
                        onSubmit()
                    } label: {
                        CountryListRow(country: country)
                            .padding(.horizontal, DesignSystem.Spacing.sm)
                            .padding(.vertical, DesignSystem.Spacing.xs)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
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
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: showFeedback)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: isCorrectAnswer)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: isInputFocused)
    }

    @ViewBuilder
    var inputTrailingContent: some View {
        if showFeedback {
            Image(systemName: isCorrectAnswer ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(isCorrectAnswer ? DesignSystem.Color.success : DesignSystem.Color.error)
                .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                .accessibilityLabel(isCorrectAnswer ? "Correct" : "Incorrect")
        } else if !typingInput.isEmpty {
            Button {
                typingInput = ""
                isInputFocused = true
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(DesignSystem.Font.callout)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Clear answer")
        }
    }

    var inputBackground: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
            .fill(DesignSystem.Color.cardBackground)
            .overlay {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                    .strokeBorder(inputBorderColor, lineWidth: 2)
            }
    }

    var correctAnswerLabel: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "checkmark")
                .font(DesignSystem.Font.caption2)
                .accessibilityHidden(true)
            Text(correctAnswerText)
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(DesignSystem.Color.success)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(DesignSystem.Color.success.opacity(0.15), in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Correct answer: \(correctAnswerText)")
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
            withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.7)) {
                showHint.toggle()
            }
            hapticsService.selection()
        } label: {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Image(systemName: showHint ? "lightbulb.fill" : "lightbulb")
                    .font(DesignSystem.Font.caption)
                    .accessibilityHidden(true)
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
        .accessibilityLabel(showHint ? "Hint: \(hintText)" : "Hint")
        .accessibilityHint(showHint ? "" : "Shows the first letters of the answer")
    }

    var submitButton: some View {
        Button { onSubmit() } label: {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                Text("Submit")
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.bold)
                Image(systemName: "arrow.right")
                    .font(DesignSystem.Font.caption)
                    .accessibilityHidden(true)
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
