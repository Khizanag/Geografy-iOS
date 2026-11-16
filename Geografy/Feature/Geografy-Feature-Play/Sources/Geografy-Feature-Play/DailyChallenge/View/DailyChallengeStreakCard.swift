import Geografy_Core_DesignSystem
import SwiftUI

/// The last seven days as marks, played or not, with a line on what keeps the streak going.
struct DailyChallengeStreakCard: View {
    // MARK: - Properties
    @Environment(\.colorSchemeContrast) private var contrast
    @ScaledMetric(relativeTo: .body) private var markSize: CGFloat = 32

    let streak: DailyChallengeStreak

    // MARK: - Body
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text(message)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 0) {
                    ForEach(streak.lastWeek) { day in
                        dayColumn(day)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(message)
        .accessibilityValue(weekSummary)
    }
}

// MARK: - Subviews
private extension DailyChallengeStreakCard {
    func dayColumn(_ day: DailyChallengeStreak.Day) -> some View {
        let isToday = day.id == streak.lastWeek.last?.id
        return VStack(spacing: DesignSystem.Spacing.xs) {
            Text(day.date.formatted(.dateTime.weekday(.narrow)))
                .font(DesignSystem.Font.caption2)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundStyle(isToday ? DesignSystem.Color.textPrimary : DesignSystem.Color.textTertiary)
            mark(for: day.state)
                .frame(width: cappedMarkSize, height: cappedMarkSize)
        }
    }

    @ViewBuilder
    func mark(for state: DailyChallengeStreak.Day.State) -> some View {
        switch state {
        case .done:
            Image(systemName: "flame.fill")
                .font(DesignSystem.Font.caption)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .frame(width: cappedMarkSize, height: cappedMarkSize)
                .background(DesignSystem.Color.orange, in: Circle())
        case .missed:
            Circle()
                .strokeBorder(missedStroke, lineWidth: 1.5)
        case .pending:
            Circle()
                .strokeBorder(DesignSystem.Color.orange, style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
        }
    }
}

// MARK: - Helpers
private extension DailyChallengeStreakCard {
    // Grows with Text Size, capped so seven marks still fit across a phone.
    var cappedMarkSize: CGFloat {
        min(markSize, 44)
    }

    var missedStroke: Color {
        contrast == .increased ? DesignSystem.Color.textSecondary : DesignSystem.Color.dividerSubtle
    }

    var message: String {
        switch streak.status {
        case .notStarted: "Play today to start a streak."
        case .atRisk(let days): "Play today to keep your \(days)-day streak going."
        case .extended(let days): "\(days)-day streak. Come back tomorrow to keep it going."
        }
    }

    var weekSummary: String {
        streak.lastWeek
            .map { day in
                let weekday = day.date.formatted(.dateTime.weekday(.wide))
                return switch day.state {
                case .done: "\(weekday), played"
                case .missed: "\(weekday), not played"
                case .pending: "\(weekday), today, not played yet"
                }
            }
            .joined(separator: "; ")
    }
}
