#if !os(tvOS)
import Geografy_Core_DesignSystem
import SwiftUI

// MARK: - Weekly Activity
extension ProfileScreen {
    public var weeklyActivitySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "This Week", icon: "flame.fill")
            CardView {
                VStack(spacing: DesignSystem.Spacing.md) {
                    streakBadgeRow
                    weekdayCirclesRow
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
    }
}

// MARK: - Weekly Activity Subviews
private extension ProfileScreen {
    var streakBadgeRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "flame.fill")
                .font(DesignSystem.Font.title3)
                .foregroundStyle(
                    streakService.currentStreak > 0
                        ? DesignSystem.Color.error
                        : DesignSystem.Color.textTertiary
                )
                .accessibilityHidden(true)
            Text("\(streakService.currentStreak)-day streak")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            Text("\(activeDaysThisWeek)/7 days")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(streakService.currentStreak) day streak, \(activeDaysThisWeek) of 7 days active this week"
        )
    }

    var weekdayCirclesRow: some View {
        HStack(spacing: 0) {
            ForEach(pastSevenDays, id: \.self) { day in
                weekdayCircle(for: day)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    func weekdayCircle(for date: Date) -> some View {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        let isActive = streakService.weekActivityDates.contains(
            calendar.startOfDay(for: date)
        )

        return VStack(spacing: DesignSystem.Spacing.xs) {
            WeekdayIndicator(isToday: isToday, isActive: isActive)

            Text(shortWeekdaySymbol(for: date))
                .font(DesignSystem.Font.caption2)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundStyle(
                    isToday
                        ? DesignSystem.Color.accent
                        : DesignSystem.Color.textSecondary
                )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(date.formatted(.dateTime.weekday(.wide)))
        .accessibilityValue(
            [isActive ? "Active" : "Missed", isToday ? "Today" : nil]
                .compactMap(\.self)
                .joined(separator: ", ")
        )
    }

    var pastSevenDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return (0..<7)
            .compactMap { calendar.date(byAdding: .day, value: -6 + $0, to: today) }
    }

    var activeDaysThisWeek: Int {
        streakService.weekActivityDates.count
    }

    func shortWeekdaySymbol(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(2))
    }
}

// MARK: - Weekday Indicator
private struct WeekdayIndicator: View {
    // MARK: - Properties
    @ScaledMetric(relativeTo: .caption2) private var diameter: CGFloat = 32

    let isToday: Bool
    let isActive: Bool

    // MARK: - Body
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    isActive
                        ? DesignSystem.Color.success.opacity(0.18)
                        : DesignSystem.Color.cardBackgroundHighlighted
                )

            Image(systemName: symbolName)
                .font(isToday ? DesignSystem.Font.subheadline.bold() : DesignSystem.Font.caption.bold())
                .foregroundStyle(isActive ? DesignSystem.Color.success : DesignSystem.Color.textSecondary)

            if isToday {
                Circle()
                    .strokeBorder(DesignSystem.Color.accent, lineWidth: 2)
            }
        }
        .frame(width: diameter, height: diameter)
    }

    private var symbolName: String {
        guard isActive else { return "minus" }
        return isToday ? "flame.fill" : "checkmark"
    }
}
#endif
