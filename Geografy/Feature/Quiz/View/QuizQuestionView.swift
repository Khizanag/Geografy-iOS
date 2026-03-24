import SwiftUI

struct QuizQuestionView: View {
    let question: QuizQuestion
    let quizType: QuizType
    let selectedOptionID: UUID?
    let correctOptionID: UUID
    let showFeedback: Bool
    @Binding var showFlagPreview: Bool
    let onSelectOption: (UUID) -> Void

    @State private var optionsVisible = false
    @State private var promptVisible = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: DesignSystem.Spacing.md)
            promptSection
                .opacity(promptVisible ? 1 : 0)
                .scaleEffect(promptVisible ? 1 : 0.94)
                .animation(.spring(response: 0.45, dampingFraction: 0.8), value: promptVisible)
            Spacer(minLength: DesignSystem.Spacing.lg)
            optionsSection
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
        .onAppear { triggerEntrance() }
        .onChange(of: question.id) { triggerEntrance() }
    }
}

// MARK: - Entrance

private extension QuizQuestionView {
    func triggerEntrance() {
        optionsVisible = false
        promptVisible = false
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.05)) {
            promptVisible = true
        }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85).delay(0.12)) {
            optionsVisible = true
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
        case .capitalQuiz, .reverseCapital, .worldRankings, .nationalSymbols:
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
            ForEach(Array(question.options.enumerated()), id: \.element.id) { index, option in
                QuizOptionButton(
                    text: option.text,
                    flagCode: nil,
                    state: optionState(for: option),
                    index: index,
                    action: { onSelectOption(option.id) }
                )
                .opacity(optionsVisible ? 1 : 0)
                .offset(y: optionsVisible ? 0 : 18)
                .animation(
                    .spring(response: 0.42, dampingFraction: 0.82)
                        .delay(0.06 * Double(index)),
                    value: optionsVisible
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
            ForEach(Array(question.options.enumerated()), id: \.element.id) { index, option in
                QuizOptionButton(
                    text: nil,
                    flagCode: option.flagCode,
                    state: optionState(for: option),
                    index: index,
                    action: { onSelectOption(option.id) }
                )
                .opacity(optionsVisible ? 1 : 0)
                .scaleEffect(optionsVisible ? 1 : 0.88)
                .animation(
                    .spring(response: 0.42, dampingFraction: 0.78)
                        .delay(0.07 * Double(index)),
                    value: optionsVisible
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
