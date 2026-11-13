import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// Past results, newest first: the day, the challenge, how long it took, and the score.
struct DailyChallengeHistorySection: View {
    // MARK: - Properties
    @ScaledMetric(relativeTo: .headline) private var dateWidth: CGFloat = 36

    let results: [DailyChallengeResult]

    @State private var showsAll = false

    private static let collapsedCount = 7

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "History", action: toggleAction)
            if results.isEmpty {
                emptyState
            } else {
                RowListCard(visibleResults, dividerInset: RowListCardLayout.dividerInset(after: dateWidth)) { result in
                    row(result)
                }
            }
        }
    }
}

// MARK: - Subviews
private extension DailyChallengeHistorySection {
    func row(_ result: DailyChallengeResult) -> some View {
        let date = DailyChallengeResult.date(forKey: result.dateKey)
        let elapsed = DailyChallengeClock.elapsed(result.timeSpentSeconds)
        return HStack(spacing: DesignSystem.Spacing.sm) {
            dateBlock(date: date, fallback: result.dateKey)
                .frame(width: dateWidth)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(typeTitle(for: result))
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(elapsed)
                    .font(DesignSystem.Font.caption)
                    .monospacedDigit()
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer(minLength: DesignSystem.Spacing.sm)
            Text("\(result.score.formatted()) pts")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .monospacedDigit()
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .rowListCardRow()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowAccessibilityLabel(result, date: date, elapsed: elapsed))
    }

    @ViewBuilder
    func dateBlock(date: Date?, fallback: String) -> some View {
        if let date {
            VStack(spacing: 0) {
                Text(date.formatted(.dateTime.day()))
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(date.formatted(.dateTime.month(.abbreviated)).uppercased())
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
        } else {
            Text(fallback)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }

    var emptyState: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.sm) {
                IconBadge("calendar", color: DesignSystem.Color.textSecondary, size: .small)
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text("No results yet")
                        .font(DesignSystem.Font.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text("Finish today's challenge to start your history.")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(DesignSystem.Spacing.md)
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Helpers
private extension DailyChallengeHistorySection {
    var visibleResults: [DailyChallengeResult] {
        showsAll ? results : Array(results.prefix(Self.collapsedCount))
    }

    var toggleAction: SectionHeaderAction? {
        guard results.count > Self.collapsedCount else { return nil }
        return SectionHeaderAction(
            showsAll ? "Show Less" : "Show All",
            systemImage: showsAll ? "chevron.up" : "chevron.down",
            accessibilityLabel: showsAll ? "Show fewer results" : "Show all \(results.count) results"
        ) {
            showsAll.toggle()
        }
    }

    func typeTitle(for result: DailyChallengeResult) -> String {
        DailyChallengeType(rawValue: result.challengeType)?.title ?? result.challengeType
    }

    func rowAccessibilityLabel(_ result: DailyChallengeResult, date: Date?, elapsed: String) -> String {
        let day = date?.formatted(date: .abbreviated, time: .omitted) ?? result.dateKey
        return "\(day), \(typeTitle(for: result)), \(result.score) of \(result.maxScore) points, in \(elapsed)"
    }
}
