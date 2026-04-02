import SwiftUI
import WidgetKit

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

    func getSnapshot(in coNowntext: Context, completion: @escaping (CountryOfDayEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CountryOfDayEntry>) -> Void) {
        let nextMidnight = Calendar.current.startOfDay(for: .now.addingTimeInterval(86_400))
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
    @Environment(\.widgetFamily) private var widgetFamily

    let entry: CountryOfDayEntry

    var body: some View {
        switch widgetFamily {
        case .accessoryInline:
            inlineView
        case .accessoryRectangular:
            rectangularView
        case .accessoryCircular:
            circularView
        default:
            smallView
        }
    }
}

// MARK: - Subviews
private extension CountryOfDayWidgetView {
    var smallView: some View {
        // swiftlint:disable:next closure_body_length
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 11, weight: .semibold))
                Text("Country of the Day")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(WidgetColors.accent)
            .widgetAccentable()

            Spacer(minLength: 6)

            Text(entry.flagEmoji)
                .font(.system(size: 36))

            Spacer(minLength: 4)

            Text(entry.countryName)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            HStack(spacing: 4) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 10))
                Text(entry.capital)
                    .font(.system(size: 11))
                    .lineLimit(1)
            }
            .foregroundStyle(.secondary)

            Spacer(minLength: 4)

            Text(entry.funFact)
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
        .widgetURL(URL(string: "geografy://home"))
    }

    var inlineView: some View {
        Label(entry.countryName, systemImage: "globe.americas.fill")
    }

    var circularView: some View {
        VStack(spacing: 2) {
            Text(entry.flagEmoji)
                .font(.system(size: 22))
            Text(entry.countryCode)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.primary)
        }
        .containerBackground(for: .widget) {
            AccessoryWidgetBackground()
        }
        .widgetURL(URL(string: "geografy://home"))
    }

    var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 10, weight: .semibold))
                Text("Country of the Day")
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(.secondary)
            .widgetAccentable()

            Text("\(entry.flagEmoji) \(entry.countryName)")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.primary)
                .lineLimit(1)

            HStack(spacing: 4) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 10))
                Text(entry.capital)
                    .font(.system(size: 11))
                    .lineLimit(1)
                Spacer()
                Text(entry.continent)
                    .font(.system(size: 10))
                    .lineLimit(1)
            }
            .foregroundStyle(.secondary)
        }
        .containerBackground(for: .widget) {
            AccessoryWidgetBackground()
        }
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
        .supportedFamilies([
            .systemSmall,
            .accessoryInline,
            .accessoryCircular,
            .accessoryRectangular,
        ])
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    CountryOfDayWidget()
} timeline: {
    CountryOfDayEntry.placeholder
}
