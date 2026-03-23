import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct CountryOfDayEntry: TimelineEntry {
    let date: Date
    let countryName: String
    let countryCode: String
    let capital: String
    let continent: String
    let flagEmoji: String
    let funFact: String

    static let placeholder = CountryOfDayEntry(
        date: .now,
        countryName: "Japan",
        countryCode: "JP",
        capital: "Tokyo",
        continent: "Asia",
        flagEmoji: "🇯🇵",
        funFact: "Population 125M · 377,975 km²"
    )
}

// MARK: - Timeline Provider

struct CountryOfDayProvider: TimelineProvider {
    func placeholder(in context: Context) -> CountryOfDayEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (CountryOfDayEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CountryOfDayEntry>) -> Void) {
        let nextMidnight = Calendar.current.startOfDay(for: .now.addingTimeInterval(86400))
        let timeline = Timeline(entries: [entry()], policy: .after(nextMidnight))
        completion(timeline)
    }

    private func entry() -> CountryOfDayEntry {
        guard let data = WidgetDataProvider.countryOfDay else {
            return .placeholder
        }
        return CountryOfDayEntry(
            date: .now,
            countryName: data.name,
            countryCode: data.code,
            capital: data.capital,
            continent: data.continent,
            flagEmoji: data.flagEmoji,
            funFact: data.funFact
        )
    }
}

// MARK: - Widget View

struct CountryOfDayWidgetView: View {
    let entry: CountryOfDayEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(WidgetColors.accent)
                Text("Country of the Day")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(WidgetColors.accent)
            }

            Spacer(minLength: 6)

            Text(entry.flagEmoji)
                .font(.system(size: 36))

            Spacer(minLength: 4)

            Text(entry.countryName)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(WidgetColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            HStack(spacing: 4) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(WidgetColors.textSecondary)
                Text(entry.capital)
                    .font(.system(size: 11))
                    .foregroundStyle(WidgetColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            Text(entry.funFact)
                .font(.system(size: 10))
                .foregroundStyle(WidgetColors.textTertiary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(14)
        .containerBackground(WidgetColors.background, for: .widget)
        .widgetURL(URL(string: "geografy://home"))
    }
}

// MARK: - Widget

struct CountryOfDayWidget: Widget {
    let kind = "CountryOfDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CountryOfDayProvider()) { entry in
            CountryOfDayWidgetView(entry: entry)
        }
        .configurationDisplayName("Country of the Day")
        .description("Discover a new country every day.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    CountryOfDayWidget()
} timeline: {
    CountryOfDayEntry.placeholder
}
