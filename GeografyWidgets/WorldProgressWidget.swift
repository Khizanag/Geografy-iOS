import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct WorldProgressEntry: TimelineEntry {
    let date: Date
    let visitedCount: Int
    let totalCountries: Int
    let levelNumber: Int
    let levelTitle: String
    let totalXP: Int
    let streak: Int

    var visitedFraction: Double {
        guard totalCountries > 0 else { return 0 }
        return Double(visitedCount) / Double(totalCountries)
    }

    var visitedPercent: Int {
        Int(visitedFraction * 100)
    }

    static let placeholder = WorldProgressEntry(
        date: .now,
        visitedCount: 24,
        totalCountries: 197,
        levelNumber: 3,
        levelTitle: "Adventurer",
        totalXP: 420,
        streak: 7
    )
}

// MARK: - Timeline Provider
struct WorldProgressProvider: TimelineProvider {
    func placeholder(in context: Context) -> WorldProgressEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (WorldProgressEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WorldProgressEntry>) -> Void) {
        let nextMidnight = Calendar.current.startOfDay(for: .now.addingTimeInterval(86400))
        let timeline = Timeline(entries: [entry()], policy: .after(nextMidnight))
        completion(timeline)
    }

    private func entry() -> WorldProgressEntry {
        WorldProgressEntry(
            date: .now,
            visitedCount: WidgetDataProvider.visitedCount,
            totalCountries: WidgetDataProvider.totalCountries,
            levelNumber: WidgetDataProvider.levelNumber,
            levelTitle: WidgetDataProvider.levelTitle,
            totalXP: WidgetDataProvider.totalXP,
            streak: WidgetDataProvider.streak
        )
    }
}

// MARK: - Widget View
struct WorldProgressWidgetView: View {
    @Environment(\.widgetFamily) private var widgetFamily

    let entry: WorldProgressEntry

    var body: some View {
        switch widgetFamily {
        case .systemMedium:
            mediumView
        case .accessoryRectangular:
            rectangularView
        default:
            largeView
        }
    }
}

// MARK: - Large View
private extension WorldProgressWidgetView {
    var largeView: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow
            travelProgressRow
            Divider()
            statsGrid
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
        .widgetURL(URL(string: "geografy://progress"))
    }

    var headerRow: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "globe")
                    .font(.system(size: 12, weight: .semibold))
                Text("World Progress")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundStyle(WidgetColors.accent)
            .widgetAccentable()

            Spacer()

            Text("Level \(entry.levelNumber)")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(WidgetColors.accent)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.fill.quaternary)
                .clipShape(Capsule())
                .widgetAccentable()
        }
    }

    var travelProgressRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(entry.visitedCount)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text("/ \(entry.totalCountries)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(entry.visitedPercent)%")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(WidgetColors.accent)
                    .widgetAccentable()
            }
            Text("Countries Visited")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)

            progressBar
        }
    }

    var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.fill.quaternary)
                    .frame(height: 8)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [WidgetColors.accent, WidgetColors.accentSecondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: max(8, geometry.size.width * entry.visitedFraction),
                        height: 8
                    )
                    .widgetAccentable()
            }
        }
        .frame(height: 8)
    }

    var statsGrid: some View {
        HStack(spacing: 0) {
            statCell(
                icon: "🔥",
                value: "\(entry.streak)",
                label: "Day Streak"
            )
            Divider()
                .frame(height: 36)
            statCell(
                icon: "⚡",
                value: "\(entry.totalXP)",
                label: "Total XP"
            )
            Divider()
                .frame(height: 36)
            statCell(
                icon: "🏅",
                value: entry.levelTitle,
                label: "Rank"
            )
        }
    }

    func statCell(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 3) {
                Text(icon)
                    .font(.system(size: 12))
                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Medium View
private extension WorldProgressWidgetView {
    var mediumView: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "globe")
                        .font(.system(size: 11, weight: .semibold))
                    Text("World Progress")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(WidgetColors.accent)
                .widgetAccentable()

                Spacer(minLength: 0)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(entry.visitedCount)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text("/ \(entry.totalCountries)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Text("Countries Visited")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)

                mediumProgressBar
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                mediumStatRow(icon: "🔥", value: "\(entry.streak)", label: "Day Streak")
                mediumStatRow(icon: "⚡", value: "\(entry.totalXP)", label: "Total XP")
                mediumStatRow(icon: "🏅", value: "Lv. \(entry.levelNumber)", label: entry.levelTitle)
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
        .widgetURL(URL(string: "geografy://progress"))
    }

    var mediumProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.fill.quaternary)
                    .frame(height: 6)
                Capsule()
                    .fill(WidgetColors.accent)
                    .frame(
                        width: max(6, geometry.size.width * entry.visitedFraction),
                        height: 6
                    )
                    .widgetAccentable()
            }
        }
        .frame(height: 6)
    }

    func mediumStatRow(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 6) {
            Text(icon)
                .font(.system(size: 14))
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(label)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - Accessory View
private extension WorldProgressWidgetView {
    var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "globe")
                    .font(.system(size: 10, weight: .semibold))
                Text("\(entry.visitedCount)/\(entry.totalCountries) Countries")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.primary)
            }
            .widgetAccentable()

            Gauge(value: entry.visitedFraction) {
                EmptyView()
            }
            .gaugeStyle(.accessoryLinearCapacity)
            .tint(WidgetColors.accent)
            .widgetAccentable()

            HStack(spacing: 8) {
                Label("\(entry.streak)d", systemImage: "flame.fill")
                Label("\(entry.totalXP) XP", systemImage: "bolt.fill")
            }
            .font(.system(size: 10))
            .foregroundStyle(.secondary)
        }
        .containerBackground(for: .widget) {
            AccessoryWidgetBackground()
        }
        .widgetURL(URL(string: "geografy://progress"))
    }
}

// MARK: - Widget
struct WorldProgressWidget: Widget {
    let kind = "WorldProgressWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WorldProgressProvider()) { entry in
            WorldProgressWidgetView(entry: entry)
        }
        .configurationDisplayName("World Progress")
        .description("See your visited countries, level, and XP at a glance.")
        .supportedFamilies([
            .systemMedium,
            .systemLarge,
            .accessoryRectangular,
        ])
    }
}

// MARK: - Preview
#Preview(as: .systemLarge) {
    WorldProgressWidget()
} timeline: {
    WorldProgressEntry.placeholder
}
