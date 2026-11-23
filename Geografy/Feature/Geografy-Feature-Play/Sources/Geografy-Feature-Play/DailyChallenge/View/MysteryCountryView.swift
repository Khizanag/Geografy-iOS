import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct MysteryCountryView: View {
    // MARK: - Properties
    @Environment(\.locale) private var locale
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(HapticsService.self) private var hapticsService
    @Environment(SoundService.self) private var soundService

    public let content: DailyChallenge.MysteryCountryContent

    @Binding var score: Int
    @Binding var revealedClueCount: Int
    @Binding var guess: String
    @Binding var guessSubmitted: Bool

    @FocusState private var isGuessFocused: Bool
    @State private var finish = PendingAction()

    public let onFinish: () -> Void

    // MARK: - Body
    public var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                regularLayout
            } else {
                compactLayout
            }
        }
        .onDisappear { finish.cancel() }
    }
}

// MARK: - Layouts
private extension MysteryCountryView {
    /// The guess sits at the bottom, where the other games put their answers, and rises with the keyboard.
    var compactLayout: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                promptSection
                cluesSection
            }
            .padding(.vertical, DesignSystem.Spacing.lg)
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaBar(edge: .bottom) {
            guessSection
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.md)
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
                .accessibilityHidden(true)
            Text("Which country is this?")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
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
        Button {
            guard !isRevealed, !guessSubmitted else { return }
            revealClue(clue)
        } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    clueIcon(clue: clue)
                    clueText(clue: clue, isRevealed: isRevealed)
                    Spacer()
                    if !isRevealed {
                        Image(systemName: "eye.slash")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                            .accessibilityHidden(true)
                    }
                }
                .padding(DesignSystem.Spacing.sm)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isRevealed ? clue.label : "Reveal \(clue.label) clue")
        .accessibilityValue(isRevealed ? clueSpokenValue(clue) : "")
        .accessibilityHint(isRevealed || guessSubmitted ? "" : "Costs \(clue.pointCost) points")
        .accessibilityRemoveTraits(isRevealed || guessSubmitted ? .isButton : [])
    }

    // A flag clue reads as "Flag": FlagView's own label spells the country code, which would give the answer away.
    func clueSpokenValue(_ clue: DailyChallenge.MysteryClue) -> String {
        clue.label == "Flag" ? "Flag shown" : clue.value
    }

    func clueIcon(clue: DailyChallenge.MysteryClue) -> some View {
        Image(systemName: clue.iconName)
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.iconPrimary)
            .frame(width: DesignSystem.Size.md)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    func clueText(
        clue: DailyChallenge.MysteryClue,
        isRevealed: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(clue.label)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
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
        AnswerField(
            String(localized: "Name the country", bundle: .module, in: locale),
            text: $guess,
            isFocused: $isGuessFocused,
            onSubmit: submitGuess
        )
    }

    var feedbackView: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.sm) {
                FlagView(
                    countryCode: target.code,
                    height: DesignSystem.Size.xxl
                )
                .accessibilityHidden(true)
                Text(target.name)
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(isCorrect ? "Correct" : "The answer was \(target.name)")
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
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Actions
private extension MysteryCountryView {
    func revealClue(_ clue: DailyChallenge.MysteryClue) {
        score = max(0, score - clue.pointCost)
        revealedClueCount += 1
        AccessibilityNotification.Announcement("\(clue.label): \(clueSpokenValue(clue)).").post()
    }

    /// Shows whether the guess was right for as long as a quiz shows its answer, then ends the challenge.
    func submitGuess() {
        guard !guessSubmitted, !guess.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isGuessFocused = false
        guessSubmitted = true
        if !isCorrect {
            score = max(0, score - 200)
        }
        AnswerFeedback(soundService: soundService, hapticsService: hapticsService).play(
            isCorrect: isCorrect,
            announcement: isCorrect
                ? String(localized: "Correct. It's \(target.name).", bundle: .module)
                : AnswerFeedback.incorrectAnnouncement(answer: target.name)
        )
        finish.schedule(after: AnswerFeedback.revealDuration) { onFinish() }
    }

    var isCorrect: Bool {
        QuizSession.matches(guess, anyOf: [target.name])
    }
}
