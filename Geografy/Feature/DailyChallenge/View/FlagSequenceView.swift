import SwiftUI

struct FlagSequenceView: View {
    let content: DailyChallenge.FlagSequenceContent
    let seed: UInt64

    @Binding var score: Int
    @Binding var currentIndex: Int

    let onFinish: () -> Void

    @State private var options: [[Country]] = []
    @State private var selectedOption: Country?
    @State private var showFeedback = false
    @State private var correctCount = 0

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            progressRow
            if currentIndex < content.countries.count {
                questionView
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, DesignSystem.Spacing.lg)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .task { prepareOptions() }
    }
}

// MARK: - Progress

private extension FlagSequenceView {
    var progressRow: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(0..<content.countries.count, id: \.self) { index in
                Capsule()
                    .fill(
                        index < currentIndex
                            ? DesignSystem.Color.accent
                            : DesignSystem.Color.cardBackgroundHighlighted
                    )
                    .frame(height: 6)
            }
        }
    }
}

// MARK: - Question

private extension FlagSequenceView {
    @ViewBuilder
    var questionView: some View {
        let country = content.countries[currentIndex]
        VStack(spacing: DesignSystem.Spacing.lg) {
            Text("Which country does this flag belong to?")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)

            FlagView(
                countryCode: country.code,
                height: DesignSystem.Size.hero
            )

            if currentIndex < options.count {
                optionsGrid(
                    options: options[currentIndex],
                    correct: country
                )
            }
        }
    }

    func optionsGrid(
        options: [Country],
        correct: Country
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(options, id: \.code) { option in
                optionButton(option: option, correct: correct)
            }
        }
    }

    func optionButton(
        option: Country,
        correct: Country
    ) -> some View {
        Button { selectOption(option, correct: correct) } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Text(option.name)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(
                        textColor(
                            option: option,
                            correct: correct
                        )
                    )
                Spacer()
                feedbackIcon(option: option, correct: correct)
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                backgroundColor(
                    option: option,
                    correct: correct
                )
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: DesignSystem.CornerRadius.medium
                )
            )
        }
        .buttonStyle(PressButtonStyle())
        .disabled(showFeedback)
    }

    @ViewBuilder
    func feedbackIcon(option: Country, correct: Country) -> some View {
        if showFeedback, option.code == correct.code {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(DesignSystem.Color.success)
        } else if showFeedback, selectedOption?.code == option.code {
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(DesignSystem.Color.error)
        }
    }
}

// MARK: - Actions

private extension FlagSequenceView {
    func prepareOptions() {
        let allCountries = content.countries
        var optionSets: [[Country]] = []

        for (index, country) in allCountries.enumerated() {
            let distractors = allCountries
                .filter { $0.code != country.code }
                .seededShuffle(seed: seed &+ UInt64(index) &* 7919)
                .prefix(3)
            var shuffledOptions = [country] + Array(distractors)
            shuffledOptions = shuffledOptions.seededShuffle(
                seed: seed &+ UInt64(index) &* 3571
            )
            optionSets.append(shuffledOptions)
        }
        options = optionSets
    }

    func selectOption(_ option: Country, correct: Country) {
        guard !showFeedback else { return }
        selectedOption = option

        let isCorrect = option.code == correct.code
        if isCorrect {
            correctCount += 1
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            withAnimation { score = max(0, score - 200) }
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
        if currentIndex + 1 < content.countries.count {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                currentIndex += 1
                selectedOption = nil
                showFeedback = false
            }
        } else {
            onFinish()
        }
    }
}

// MARK: - Helpers

private extension FlagSequenceView {
    func textColor(option: Country, correct: Country) -> Color {
        guard showFeedback else {
            return DesignSystem.Color.textPrimary
        }
        if option.code == correct.code {
            return DesignSystem.Color.success
        }
        if selectedOption?.code == option.code {
            return DesignSystem.Color.error
        }
        return DesignSystem.Color.textSecondary
    }

    func backgroundColor(option: Country, correct: Country) -> Color {
        guard showFeedback else {
            return DesignSystem.Color.cardBackground
        }
        if option.code == correct.code {
            return DesignSystem.Color.success.opacity(0.15)
        }
        if selectedOption?.code == option.code {
            return DesignSystem.Color.error.opacity(0.15)
        }
        return DesignSystem.Color.cardBackground
    }
}
