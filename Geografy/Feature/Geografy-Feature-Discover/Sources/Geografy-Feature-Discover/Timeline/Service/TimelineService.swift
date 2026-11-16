import Foundation
import Geografy_Core_Common

@Observable
public final class TimelineService {
    public init() {}
    public private(set) var events: [HistoricalEvent] = [] {
        didSet { clearCaches() }
    }

    // The slider and the "This Day" section ask on every year step; these keep their answers between steps.
    @ObservationIgnored private var continentCache: (countryCount: Int, continents: [String: Country.Continent])?
    @ObservationIgnored private var decadeCountCache: (filter: TimelineFilter, countryCount: Int, counts: [Int: Int])?
    @ObservationIgnored private var todayCache: (month: Int?, day: Int?, events: [HistoricalEvent])?

    /// Decodes the bundled events the first time; later calls keep what's loaded.
    public func loadEvents() {
        guard events.isEmpty else { return }
        guard let url = Bundle.main.url(
            forResource: "historical_events",
            withExtension: "json"
        ),
              let data = try? Data(contentsOf: url) else {
            return
        }

        do {
            events = try JSONDecoder().decode([HistoricalEvent].self, from: data)
        } catch {
            print("Failed to decode historical events: \(error)")
        }
    }

    /// Replaces the events, as `loadEvents()` does from the bundle.
    func setEvents(_ events: [HistoricalEvent]) {
        self.events = events
    }
}

// MARK: - Queries
extension TimelineService {
    public func events(
        for year: Int,
        filter: TimelineFilter,
        countries: [Country]
    ) -> [HistoricalEvent] {
        let continents = continentsByCode(countries)
        return events.filter { event in
            event.year == year
                && matchesFilter(event, filter: filter, continents: continents)
        }
    }

    public func events(
        inRange range: ClosedRange<Int>,
        filter: TimelineFilter,
        countries: [Country]
    ) -> [HistoricalEvent] {
        let continents = continentsByCode(countries)
        return events.filter { event in
            range.contains(event.year)
                && matchesFilter(event, filter: filter, continents: continents)
        }
    }

    public func todayEvents(countries: [Country]) -> [HistoricalEvent] {
        let today = Calendar.current.dateComponents([.month, .day], from: Date())
        if let cached = todayCache, cached.month == today.month, cached.day == today.day {
            return cached.events
        }
        let matches = events
            .filter { $0.occurs(onMonth: today.month, day: today.day) }
            .sorted(by: \.year)
        todayCache = (today.month, today.day, matches)
        return matches
    }

    public func decades(in range: ClosedRange<Int>) -> [Int] {
        let start = (range.lowerBound / 10) * 10
        let end = (range.upperBound / 10) * 10
        return stride(from: start, through: end, by: 10).map { $0 }
    }

    public func eventCount(
        forDecade decade: Int,
        filter: TimelineFilter,
        countries: [Country]
    ) -> Int {
        eventCountsByDecade(filter: filter, countries: countries)[decade] ?? 0
    }
}

// MARK: - Helpers
private extension TimelineService {
    func clearCaches() {
        decadeCountCache = nil
        todayCache = nil
    }

    func continentsByCode(_ countries: [Country]) -> [String: Country.Continent] {
        if let cached = continentCache, cached.countryCount == countries.count {
            return cached.continents
        }
        let continents = Dictionary(
            countries.map { ($0.code, $0.continent) },
            uniquingKeysWith: { first, _ in first }
        )
        continentCache = (countries.count, continents)
        return continents
    }

    /// Events per decade, keyed by the decade's first year, counted in one pass for the filter.
    func eventCountsByDecade(filter: TimelineFilter, countries: [Country]) -> [Int: Int] {
        if let cached = decadeCountCache, cached.filter == filter, cached.countryCount == countries.count {
            return cached.counts
        }
        let continents = continentsByCode(countries)
        var counts: [Int: Int] = [:]
        for event in events where matchesFilter(event, filter: filter, continents: continents) {
            let decade = Int((Double(event.year) / 10).rounded(.down)) * 10
            counts[decade, default: 0] += 1
        }
        decadeCountCache = (filter, countries.count, counts)
        return counts
    }

    func matchesFilter(
        _ event: HistoricalEvent,
        filter: TimelineFilter,
        continents: [String: Country.Continent]
    ) -> Bool {
        if let eventType = filter.eventType, event.type != eventType {
            return false
        }
        if let continent = filter.continent {
            return continents[event.countryCode] == continent
        }
        return true
    }
}
