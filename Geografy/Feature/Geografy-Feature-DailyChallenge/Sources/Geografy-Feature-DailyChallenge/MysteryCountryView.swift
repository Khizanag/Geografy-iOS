import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct MysteryCountryView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(HapticsService.self) private var hapticsService

    public let content: DailyChallenge.MysteryCountryContent

    @Binding var score: Int
    @Binding var revealedClueCount: Int
    @Binding var guess: String
    @Binding var guessSubmitted: Bool

    public let onFinish: () -> Void

    public var body: some View {
        if horizontalSizeClass == .regular {
            regularLayout
        } else {
            compactLayout
        }
    }
}

// MARK: - Layouts
private extension MysteryCountryView {
    var compactLayout: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                promptSection
                cluesSection
                guessSection
            }
            .padding(.vertical, DesignSystem.Spacing.lg)
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }

    var regularLayout: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.lg) {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    promptSection
                    cluesSection
                }
                .padding(.vertical, DesignSystem.Spacing.lg)
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
            .frame(maxWidth: .infinity)

            ScrollView {
                guessSection
                    .padding(.vertical, DesignSystem.Spacing.lg)
                    .padding(.horizontal, DesignSystem.Spacing.md)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Prompt
private extension MysteryCountryView {
    var promptSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "questionmark.circle.fill")
                .font(DesignSystem.Font.displaySmall)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("Which country is this?")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("Reveal clues to narrow it down")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }
}

// MARK: - Clues
private extension MysteryCountryView {
    var cluesSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(content.clues) { clue in
                clueRow(
                    clue: clue,
                    isRevealed: clue.id < revealedClueCount
                )
            }
        }
    }

    func clueRow(
        clue: DailyChallenge.MysteryClue,
        isRevealed: Bool
    ) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                clueIcon(clue: clue)
                clueText(clue: clue, isRevealed: isRevealed)
                Spacer()
                if !isRevealed {
                    Image(systemName: "eye.slash")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
            }
            .padding(DesignSystem.Spacing.sm)
        }
        .onTapGesture {
            guard !isRevealed, !guessSubmitted else { return }
            revealClue(cost: clue.pointCost)
        }
    }

    func clueIcon(clue: DailyChallenge.MysteryClue) -> some View {
        Image(systemName: clue.iconName)
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.accent)
            .frame(width: DesignSystem.Size.md)
    }

    @ViewBuilder
    func clueText(
        clue: DailyChallenge.MysteryClue,
        isRevealed: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(clue.label)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
            if isRevealed {
                if clue.label == "Flag" {
                    FlagView(countryCode: clue.value, height: 32)
                } else {
                    Text(clue.value)
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                }
            } else {
                Text("Tap to reveal (-\(clue.pointCost) pts)")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
    }
}

// MARK: - Guess
private extension MysteryCountryView {
    var target: Country { content.targetCountry }

    var guessSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            if guessSubmitted {
                feedbackView
            } else {
                inputView
            }
        }
    }

    var inputView: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            TextField("Type country name...", text: $guess)
                .font(DesignSystem.Font.body)
                .padding(DesignSystem.Spacing.sm)
                .background(DesignSystem.Color.cardBackground)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: DesignSystem.CornerRadius.medium
                    )
                )
                .autocorrectionDisabled()

            Button { submitGuess() } label: {
                Text("Submit Guess")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.sm)
            }
            .buttonStyle(.glass)
            .disabled(guess.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty)
        }
    }

    var feedbackView: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                FlagView(
                    countryCode: target.code,
                    height: DesignSystem.Size.xxl
                )
                Text(target.name)
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(isCorrect ? "Correct!" : "The answer was \(target.name)")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(
                        isCorrect
                            ? DesignSystem.Color.success
                            : DesignSystem.Color.error
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Actions
private extension MysteryCountryView {
    func revealClue(cost: Int) {
        score = max(0, score - cost)
        revealedClueCount += 1
    }

    func submitGuess() {
        guessSubmitted = true
        if !isCorrect {
            score = max(0, score - 200)
        }
        hapticsService.notification(isCorrect ? .success : .error)
        onFinish()
    }

    var isCorrect: Bool {
        guess
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() == target.name.lowercased()
    }
}
