import Foundation

@Observable
final class TimelineService {
    private(set) var events: [HistoricalEvent] = []

    func loadEvents() {
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
}

// MARK: - Queries

extension TimelineService {
    func events(
        for year: Int,
        filter: TimelineFilter,
        countries: [Country]
    ) -> [HistoricalEvent] {
        events.filter { event in
            event.year == year
                && matchesFilter(event, filter: filter, countries: countries)
        }
    }

    func events(
        inRange range: ClosedRange<Int>,
        filter: TimelineFilter,
        countries: [Country]
    ) -> [HistoricalEvent] {
        events.filter { event in
            range.contains(event.year)
                && matchesFilter(event, filter: filter, countries: countries)
        }
    }

    func todayEvents(countries: [Country]) -> [HistoricalEvent] {
        events
            .filter(\.matchesToday)
            .sorted { $0.year < $1.year }
    }

    func decades(in range: ClosedRange<Int>) -> [Int] {
        let start = (range.lowerBound / 10) * 10
        let end = (range.upperBound / 10) * 10
        return stride(from: start, through: end, by: 10).map { $0 }
    }

    func eventCount(
        forDecade decade: Int,
        filter: TimelineFilter,
        countries: [Country]
    ) -> Int {
        let range = decade...(decade + 9)
        return events.filter { event in
            range.contains(event.year)
                && matchesFilter(event, filter: filter, countries: countries)
        }.count
    }
}

// MARK: - Helpers

private extension TimelineService {
    func matchesFilter(
        _ event: HistoricalEvent,
        filter: TimelineFilter,
        countries: [Country]
    ) -> Bool {
        if let eventType = filter.eventType, event.type != eventType {
            return false
        }
        if let continent = filter.continent {
            guard let country = countries.first(where: {
                $0.code == event.countryCode
            }) else {
                return false
            }
            if country.continent != continent {
                return false
            }
        }
        return true
    }
}
