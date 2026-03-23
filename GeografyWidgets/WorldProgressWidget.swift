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
    let entry: WorldProgressEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow
            travelProgressRow
            Divider().background(WidgetColors.divider)
            statsGrid
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(16)
        .containerBackground(WidgetColors.background, for: .widget)
        .widgetURL(URL(string: "geografy://progress"))
    }
}

// MARK: - Subviews

private extension WorldProgressWidgetView {
    var headerRow: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "globe")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(WidgetColors.accent)
                Text("World Progress")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(WidgetColors.accent)
            }
            Spacer()
            Text("Level \(entry.levelNumber)")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(WidgetColors.accent)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(WidgetColors.accent.opacity(0.15))
                .clipShape(Capsule())
        }
    }

    var travelProgressRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(entry.visitedCount)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(WidgetColors.textPrimary)
                Text("/ \(entry.totalCountries)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(WidgetColors.textSecondary)
                Spacer()
                Text("\(entry.visitedPercent)%")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(WidgetColors.accent)
            }
            Text("Countries Visited")
                .font(.system(size: 11))
                .foregroundStyle(WidgetColors.textSecondary)

            progressBar
        }
    }

    var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(WidgetColors.cardBackground)
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
                .background(WidgetColors.divider)
                .frame(height: 36)
            statCell(
                icon: "⚡",
                value: "\(entry.totalXP)",
                label: "Total XP"
            )
            Divider()
                .background(WidgetColors.divider)
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
                    .foregroundStyle(WidgetColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(WidgetColors.textTertiary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
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
        .supportedFamilies([.systemLarge])
    }
}

// MARK: - Preview

#Preview(as: .systemLarge) {
    WorldProgressWidget()
} timeline: {
    WorldProgressEntry.placeholder
}
