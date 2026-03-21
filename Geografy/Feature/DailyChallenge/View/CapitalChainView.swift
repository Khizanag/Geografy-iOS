import SwiftUI

struct CapitalChainView: View {
    let content: DailyChallenge.CapitalChainContent

    @Binding var score: Int
    @Binding var currentStep: Int

    let onFinish: () -> Void

    @State private var selectedOption: Country?
    @State private var showFeedback = false
    @State private var correctCount = 0

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                startSection
                if currentStep < content.chainSteps.count {
                    stepView(
                        step: content.chainSteps[currentStep]
                    )
                }
            }
            .padding(.vertical, DesignSystem.Spacing.lg)
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Start Section

private extension CapitalChainView {
    var startSection: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Starting Point")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                HStack(spacing: DesignSystem.Spacing.sm) {
                    FlagView(
                        countryCode: content.startingCountry.code,
                        height: DesignSystem.Size.md
                    )
                    VStack(alignment: .leading) {
                        Text(content.startingCapital)
                            .font(DesignSystem.Font.headline)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text(content.startingCountry.name)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                }
                progressDots
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.md)
        }
    }

    var progressDots: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(0..<content.chainSteps.count, id: \.self) { index in
                Circle()
                    .fill(
                        index < currentStep
                            ? DesignSystem.Color.accent
                            : DesignSystem.Color.cardBackgroundHighlighted
                    )
                    .frame(
                        width: DesignSystem.Spacing.xs,
                        height: DesignSystem.Spacing.xs
                    )
            }
        }
    }
}

// MARK: - Step View

private extension CapitalChainView {
    func stepView(step: DailyChallenge.ChainStep) -> some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text("Find a country in \(step.continent.displayName)")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)

            Text("with capital: \(step.expectedCountry.capital)")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.accent)

            ForEach(step.options, id: \.code) { option in
                optionButton(option: option, step: step)
            }
        }
    }

    func optionButton(
        option: Country,
        step: DailyChallenge.ChainStep
    ) -> some View {
        Button { selectOption(option, step: step) } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                FlagView(
                    countryCode: option.code,
                    height: DesignSystem.Spacing.lg
                )
                Text(option.name)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(textColor(
                        option: option,
                        step: step
                    ))
                Spacer()
                feedbackIcon(option: option, step: step)
            }
            .padding(DesignSystem.Spacing.md)
            .background(backgroundColor(
                option: option,
                step: step
            ))
            .clipShape(
                RoundedRectangle(
                    cornerRadius: DesignSystem.CornerRadius.medium
                )
            )
        }
        .buttonStyle(GeoPressButtonStyle())
        .disabled(showFeedback)
    }

    @ViewBuilder
    func feedbackIcon(
        option: Country,
        step: DailyChallenge.ChainStep
    ) -> some View {
        if showFeedback, option.code == step.expectedCountry.code {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(DesignSystem.Color.success)
        } else if showFeedback,
                  selectedOption?.code == option.code {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(DesignSystem.Color.error)
        }
    }
}

// MARK: - Actions

private extension CapitalChainView {
    func selectOption(
        _ option: Country,
        step: DailyChallenge.ChainStep
    ) {
        guard !showFeedback else { return }
        selectedOption = option

        let isCorrect = option.code == step.expectedCountry.code
        if isCorrect {
            correctCount += 1
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            withAnimation { score = max(0, score - 250) }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            showFeedback = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            advance()
        }
    }

    func advance() {
        if currentStep + 1 < content.chainSteps.count {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                currentStep += 1
                selectedOption = nil
                showFeedback = false
            }
        } else {
            onFinish()
        }
    }
}

// MARK: - Helpers

private extension CapitalChainView {
    func textColor(
        option: Country,
        step: DailyChallenge.ChainStep
    ) -> Color {
        guard showFeedback else {
            return DesignSystem.Color.textPrimary
        }
        if option.code == step.expectedCountry.code {
            return DesignSystem.Color.success
        }
        if selectedOption?.code == option.code {
            return DesignSystem.Color.error
        }
        return DesignSystem.Color.textSecondary
    }

    func backgroundColor(
        option: Country,
        step: DailyChallenge.ChainStep
    ) -> Color {
        guard showFeedback else {
            return DesignSystem.Color.cardBackground
        }
        if option.code == step.expectedCountry.code {
            return DesignSystem.Color.success.opacity(0.15)
        }
        if selectedOption?.code == option.code {
            return DesignSystem.Color.error.opacity(0.15)
        }
        return DesignSystem.Color.cardBackground
    }
}
