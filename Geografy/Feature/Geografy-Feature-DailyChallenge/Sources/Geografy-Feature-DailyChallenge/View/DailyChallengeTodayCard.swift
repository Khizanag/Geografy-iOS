import Geografy_Core_DesignSystem
import SwiftUI

/// The one place for today: which challenge it is and how long is left to play it, or, once it's done,
/// today's result and when the next one starts.
struct DailyChallengeTodayCard: View {
    // MARK: - Properties
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let challenge: DailyChallenge
    let result: DailyChallengeResult?

    // MARK: - Body
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                titleRow
                if let result {
                    resultRow(result)
                    Divider()
                    nextChallengeRow
                } else {
                    detailPills
                }
            }
            .padding(DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Subviews
private extension DailyChallengeTodayCard {
    var titleRow: some View {
        adaptiveStack {
            IconBadge(challenge.type.iconName, color: DesignSystem.Color.orange, size: .large)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text("Today's Challenge")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Text(challenge.type.title)
                    .font(DesignSystem.Font.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text(challenge.type.subtitle)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }

    var detailPills: some View {
        FlowLayout(spacing: DesignSystem.Spacing.xs) {
            InfoPill(roundsLabel, systemImage: roundsIcon)
            InfoPill("Up to \(DailyChallengeResult.defaultMaxScore.formatted()) pts", systemImage: "star.fill")
            TimelineView(.everyMinute) { context in
                InfoPill(
                    "Ends in \(DailyChallengeClock.countdown(from: context.date))",
                    systemImage: "hourglass"
                )
            }
        }
        .accessibilityElement(children: .combine)
    }

    func resultRow(_ result: DailyChallengeResult) -> some View {
        let elapsed = DailyChallengeClock.elapsed(result.timeSpentSeconds)
        return adaptiveStack {
            stat(title: "Score", value: result.score.formatted(), unit: "/ \(result.maxScore.formatted())")
            stat(title: "Time", value: elapsed, unit: nil)
            if !dynamicTypeSize.isAccessibilitySize {
                Spacer(minLength: DesignSystem.Spacing.sm)
            }
            InfoPill("Done", systemImage: "checkmark", style: .tinted(DesignSystem.Color.orange))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Done. Score \(result.score) of \(result.maxScore), in \(elapsed)")
    }

    func stat(title: String, value: String, unit: String?) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(title)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            HStack(alignment: .firstTextBaseline, spacing: DesignSystem.Spacing.xxs) {
                Text(value)
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                if let unit {
                    Text(unit)
                        .font(DesignSystem.Font.subheadline)
                        .monospacedDigit()
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
            }
        }
    }

    var nextChallengeRow: some View {
        TimelineView(.everyMinute) { context in
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "clock")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .accessibilityHidden(true)
                Text("Next challenge in")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Spacer(minLength: DesignSystem.Spacing.sm)
                Text(DailyChallengeClock.countdown(from: context.date))
                    .font(DesignSystem.Font.headline)
                    .monospacedDigit()
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }
            .accessibilityElement(children: .combine)
        }
    }

    func adaptiveStack(@ViewBuilder content: () -> some View) -> some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: DesignSystem.Spacing.sm))
            : AnyLayout(HStackLayout(alignment: .center, spacing: DesignSystem.Spacing.md))
        return layout(content)
    }
}

// MARK: - Helpers
private extension DailyChallengeTodayCard {
    var roundsLabel: String {
        switch challenge.content {
        case .mysteryCountry(let content): "\(content.clues.count) clues"
        case .flagSequence(let content): "\(content.countries.count) flags"
        case .capitalChain(let content): "\(content.chainSteps.count) continents"
        }
    }

    var roundsIcon: String {
        switch challenge.content {
        case .mysteryCountry: "lightbulb.fill"
        case .flagSequence: "flag.fill"
        case .capitalChain: "globe"
        }
    }
}
