import SwiftUI
import WidgetKit

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
        let nextMidnight = Calendar.current.startOfDay(for: .now.addingTimeInterval(86_400))
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
    @Environment(\.widgetFamily) private var widgetFamily

    let entry: DailyStreakEntry

    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            circularView
        case .accessoryRectangular:
            rectangularView
        case .accessoryInline:
            inlineView
        default:
            mediumView
        }
    }
}

// MARK: - Subviews
private extension DailyStreakWidgetView {
    var mediumView: some View {
        HStack(spacing: 16) {
            streakColumn
            Divider()
            xpColumn
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
        .widgetURL(URL(string: "geografy://streak"))
    }

    var streakColumn: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Text("🔥")
                    .font(.system(size: 20))
                Text("\(entry.streak)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }
            Text("Day Streak")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
            Text(streakEncouragement)
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
        }
        .frame(maxHeight: .infinity, alignment: .leading)
    }

    var xpColumn: some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Level \(entry.levelNumber)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WidgetColors.accent)
                    .widgetAccentable()
                Text(entry.levelTitle)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            xpProgressBar

            Text("\(entry.totalXP) XP")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var xpProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.fill.quaternary)
                    .frame(height: 6)
                Capsule()
                    .fill(WidgetColors.accent)
                    .frame(width: geometry.size.width * entry.progressFraction, height: 6)
                    .widgetAccentable()
            }
        }
        .frame(height: 6)
    }

    var circularView: some View {
        VStack(spacing: 2) {
            Text("🔥")
                .font(.system(size: 18))
            Text("\(entry.streak)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .containerBackground(for: .widget) {
            AccessoryWidgetBackground()
        }
        .widgetURL(URL(string: "geografy://streak"))
    }

    var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Text("🔥")
                    .font(.system(size: 12))
                Text("\(entry.streak) Day Streak")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.primary)
            }

            HStack(spacing: 4) {
                Text("Level \(entry.levelNumber)")
                    .font(.system(size: 11, weight: .semibold))
                    .widgetAccentable()
                Text("·")
                Text(entry.levelTitle)
                    .font(.system(size: 11))
            }
            .foregroundStyle(.secondary)

            Gauge(value: entry.progressFraction) {
                EmptyView()
            }
            .gaugeStyle(.accessoryLinearCapacity)
            .tint(WidgetColors.accent)
            .widgetAccentable()
        }
        .containerBackground(for: .widget) {
            AccessoryWidgetBackground()
        }
        .widgetURL(URL(string: "geografy://streak"))
    }

    var inlineView: some View {
        Label("🔥 \(entry.streak) Day Streak", systemImage: "flame.fill")
    }
}

// MARK: - Helpers
private extension DailyStreakWidgetView {
    var streakEncouragement: String {
        switch entry.streak {
        case 0: "Start your streak today!"
        case 1...2: "Great start!"
        case 3...6: "Keep it up!"
        case 7...13: "One week strong!"
        case 14...29: "You're on fire!"
        default: "Unstoppable!"
        }
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
        .supportedFamilies([
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}

// MARK: - Preview
#Preview(as: .systemMedium) {
    DailyStreakWidget()
} timeline: {
    DailyStreakEntry.placeholder
}
