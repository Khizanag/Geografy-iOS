import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct DailyStreakEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let totalXP: Int
    let levelNumber: Int
    let levelTitle: String
    let progressFraction: Double

    static let placeholder = DailyStreakEntry(
        date: .now,
        streak: 7,
        totalXP: 420,
        levelNumber: 3,
        levelTitle: "Adventurer",
        progressFraction: 0.6
    )
}

// MARK: - Timeline Provider

struct DailyStreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyStreakEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyStreakEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyStreakEntry>) -> Void) {
        let nextMidnight = Calendar.current.startOfDay(for: .now.addingTimeInterval(86400))
        let timeline = Timeline(entries: [entry()], policy: .after(nextMidnight))
        completion(timeline)
    }

    private func entry() -> DailyStreakEntry {
        DailyStreakEntry(
            date: .now,
            streak: WidgetDataProvider.streak,
            totalXP: WidgetDataProvider.totalXP,
            levelNumber: WidgetDataProvider.levelNumber,
            levelTitle: WidgetDataProvider.levelTitle,
            progressFraction: WidgetDataProvider.progressFraction
        )
    }
}

// MARK: - Widget View

struct DailyStreakWidgetView: View {
    let entry: DailyStreakEntry

    var body: some View {
        HStack(spacing: 16) {
            streakColumn
            Divider()
                .background(WidgetColors.divider)
            xpColumn
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(14)
        .containerBackground(WidgetColors.background, for: .widget)
        .widgetURL(URL(string: "geografy://streak"))
    }
}

// MARK: - Subviews

private extension DailyStreakWidgetView {
    var streakColumn: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Text("🔥")
                    .font(.system(size: 20))
                Text("\(entry.streak)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(WidgetColors.textPrimary)
            }
            Text("Day Streak")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(WidgetColors.textSecondary)
            Spacer(minLength: 0)
            Text("Keep it up!")
                .font(.system(size: 10))
                .foregroundStyle(WidgetColors.textTertiary)
        }
        .frame(maxHeight: .infinity, alignment: .leading)
    }

    var xpColumn: some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Level \(entry.levelNumber)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WidgetColors.accent)
                Text(entry.levelTitle)
                    .font(.system(size: 11))
                    .foregroundStyle(WidgetColors.textSecondary)
                    .lineLimit(1)
            }

            xpProgressBar

            Text("\(entry.totalXP) XP")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(WidgetColors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var xpProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(WidgetColors.cardBackground)
                    .frame(height: 6)
                Capsule()
                    .fill(WidgetColors.accent)
                    .frame(width: geometry.size.width * entry.progressFraction, height: 6)
            }
        }
        .frame(height: 6)
    }
}

// MARK: - Widget

struct DailyStreakWidget: Widget {
    let kind = "DailyStreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyStreakProvider()) { entry in
            DailyStreakWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Streak")
        .description("Track your learning streak and XP progress.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
    DailyStreakWidget()
} timeline: {
    DailyStreakEntry.placeholder
}
