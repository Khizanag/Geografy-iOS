import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct QuizTypingInputView: View {
    // MARK: - Properties
    @Environment(\.locale) private var locale
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

    @State private var suggestions: [Country] = []
    @State private var foldedNames: [String] = []

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
            .onChange(of: typingInput) { _, newValue in
                updateSuggestions(for: newValue)
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
                                .fill(DesignSystem.Color.accent.opacity(DesignSystem.Opacity.tint))
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

            if showAutocomplete, !suggestions.isEmpty, isInputFocused, !showFeedback {
                suggestionsList
            }

            inputField
        }
    }

    var suggestionsList: some View {
        CardView(cornerRadius: DesignSystem.CornerRadius.medium) {
            VStack(spacing: 0) {
                ForEach(suggestions) { country in
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
        AnswerField(
            String(localized: "Type your answer", bundle: .module, in: locale),
            text: $typingInput,
            isFocused: $isInputFocused,
            feedback: feedback,
            onSubmit: onSubmit
        )
        .disabled(showFeedback)
    }

    var correctAnswerLabel: some View {
        InfoPill(correctAnswerText, systemImage: "checkmark", style: .tinted(DesignSystem.Color.success))
            .accessibilityElement(children: .combine)
        .accessibilityLabel("Correct answer: \(correctAnswerText)")
    }

    var controlsRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            hintButton
            Spacer()
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
}

// MARK: - Suggestions
private extension QuizTypingInputView {
    func updateSuggestions(for input: String) {
        guard showAutocomplete, !input.isEmpty else {
            suggestions = []
            return
        }
        if foldedNames.count != countries.count {
            foldedNames = countries.map { Self.fold($0.name) }
        }
        let query = Self.fold(input)
        suggestions = Array(
            zip(countries, foldedNames)
                .lazy
                .filter { $0.1.contains(query) }
                .prefix(5)
                .map(\.0)
        )
    }

    static func fold(_ text: String) -> String {
        text.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
    }
}

// MARK: - Helpers
private extension QuizTypingInputView {
    var feedback: AnswerField.Feedback {
        guard showFeedback else { return .none }
        return isCorrectAnswer ? .correct : .incorrect
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
